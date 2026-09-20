# Rebuild NUC From Scratch

The NUC runs the stable core of the homelab via k3s: DNS, a container registry (`registry.home.gaborzeller.com`), a CPU-only Ollama instance (`ollama-cpu.home.gaborzeller.com`, embedding models only — no GPU), the Star Wars Armada MCP server (`starwars-armada.home.gaborzeller.com`, retrieval only — queries `ollama-cpu` for embeddings, generation is handled by the calling client), Postgres, Jellyfin, monitoring, and the homepage dashboard. Kubernetes manifests are applied as one batch (Phase 3) rather than resource-by-resource: a Pod that can't pull its image yet just retries (`ImagePullBackOff`) until the dependency shows up, it doesn't block anything else in the same apply. The only hard ordering rule is CRDs/operators before the CRs that use them (that's why CNPG installs before the manifests batch). Phases must run in sequence; within a phase, order doesn't matter. Manual/external steps are called out explicitly — everything else is a `mise run` task.

## Phase 0 — Local machine setup

1. Install `mise`, `age`, and `sops`.
2. Generate the age key used to decrypt `secrets.yaml`:
   ```sh
   mkdir -p ~/.age
   age-keygen -o ~/.age/homelab.txt
   chmod 600 ~/.age/homelab.txt
   ```
   See [secret management](../secret-management.md) for how `secrets.yaml` encryption/editing works day-to-day.
3. Generate an SSH key and copy it to the NUC:
   ```sh
   ssh-keygen -t ed25519 -f ~/.ssh/homelab_admin -C "homelab"
   ssh-copy-id -i ~/.ssh/homelab_admin.pub <user>@<nuc-ip>
   ```
4. Add the NUC to `~/.ssh/config`. The `Host` alias must match the Ansible inventory hostname (`homelabnuc` in `ansible/inventory.yaml`) since Ansible connects by that name with no `ansible_host` override:
   ```
   Host homelabnuc
     HostName <nuc-ip>
     User gaze
     IdentityFile ~/.ssh/homelab_admin
   ```
5. Copy `.env.example` to `.env` and fill in the values (`HOMELAB_USER`, `HOMELAB_NUC_HOST`, etc. — these back `mise run bootstrap`'s Docker contexts, not the SSH config above):
   ```sh
   cp .env.example .env
   ```
6. `mise run bootstrap` — creates the `homelab-nuc` Docker context. Safe to run even if the desktop is off; it only registers contexts locally, it doesn't connect.

## Phase 1 — Host provisioning + NUC infra

1. `mise run ansible:deploy:nuc` — baseline roles (including `docker`, then `homelab`, which creates the `homelab` Docker network needed by `infra-nuc/`) + infra host roles. This is where **k3s actually gets installed** and the kubeconfig is fetched to `~/.kube/homelab-nuc.yaml`.
2. `mise run docker:deploy:infra-nuc` — brings up Technitium DNS.
3. `mise run technitium:bootstrap-api-key`
4. `mise run dns:configure-zone`
5. `mise run dns:configure-blocking` (optional — ad blocking toggle, safe to skip/defer)

At the end of this phase the k3s cluster exists but has nothing deployed to it yet.

## Phase 2 — Kubernetes secrets + operators

6. `mise run verify-cloudflare-tokens` (optional sanity check)
7. `mise run k8s:deploy:secrets` — creates the Cloudflare, Grafana, homepage, and ebay-scraper Secrets in one pass.
   > **Conditional**: the homepage Secret embeds `jellyfin_api_key` from `secrets.yaml`. If Jellyfin's own data (`/srv/jellyfin`) survived the rebuild, the existing key in `secrets.yaml` is still valid and this is a non-issue. If Jellyfin's data was wiped too, this step will embed a stale/empty key — re-run this task after Phase 4 (Jellyfin bootstrap) completes; it's idempotent.
8. `mise run k8s:install-cnpg-operator`

## Phase 3 — Apply all manifests

9. `mise run k8s:deploy:manifests` — Traefik config, Registry, Ollama (CPU), the Star Wars Armada MCP server, Jellyfin, Postgres Cluster (references the ebay-scraper Secret from step 7), Grafana, homepage, Prometheus, Loki, Alloy, node-exporter, kube-state-metrics, intel-gpu-plugin. Some pods (Postgres, Jellyfin) take a moment to reach Ready.
   > **Manual/external step**: `k8s/starwars-armada/deployment.yaml` references `registry.home.gaborzeller.com/homelab/starwars-armada:latest` — an image built from its own separate source repo. Until that image is built and pushed, its pod just sits in `ImagePullBackOff`; it doesn't block anything else in this step.
10. `mise run k8s:bootstrap-postgres-credentials` — once the Postgres cluster is Ready.
11. `mise run k8s:grant-ebay-scraper-privileges` — once the cluster is Ready and the `ebay_scraper` managed role exists.
12. **Manual step**: once the `ollama-cpu` pod is Running, `mise run ollama-cpu:pull-models` — Ollama doesn't ship or auto-pull any models, so this has to be triggered by hand (`kubectl exec`s into the pod and pulls each model listed in `scripts/ollama-cpu-pull-models.sh`, currently just `mxbai-embed-large`). The pulled model persists on its PVC, so this is only needed once per fresh volume.

## Phase 4 — Jellyfin first-run (manual, one-time per fresh Jellyfin volume)

13. **Manual step**: open `https://jellyfin.home.gaborzeller.com`, complete the setup wizard, set the `admin` password to match `jellyfin_admin_password` in `secrets.yaml`. There's no headless way to do this — Jellyfin has no API for first-run setup in this repo's flow.
14. `mise run jellyfin:bootstrap-api-key`
15. `mise run jellyfin:configure`
16. If step 7 ran before this phase, re-run `mise run k8s:deploy:secrets` to pick up the fresh `jellyfin_api_key` into the homepage widget Secret.

## Day-2 (not part of a rebuild)

- `mise run jellyfin:scan` — after adding new media files.
- `mise run dns:configure-blocking` — toggle ad blocking anytime.
- `mise run ollama-cpu:pull-models` — after adding a new model to `scripts/ollama-cpu-pull-models.sh`.
