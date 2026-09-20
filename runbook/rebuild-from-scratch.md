# Rebuild From Scratch

This is really two independent rebuild tracks that happen to share one machine's worth of local setup: **Track A (NUC / Kubernetes)** is the stable core cluster, and **Track B (Desktop / Docker Compose)** runs the GPU workloads and is still transitional — it's plain Docker Compose today, with a planned (not yet done) migration into k3s. Nothing in the k3s cluster currently pulls from the desktop's self-hosted registry, so the two tracks have no runtime dependency on each other right now — you can bring either one up, tear it down, or leave it off without touching the other. Don't assume the desktop is powered on when working through Track A, or vice versa; it's routinely off. Within a track, phases must run in sequence; within a phase, order doesn't matter. Manual/external steps are called out explicitly — everything else is a `mise run` task.

## Phase 0 — Local machine (shared, one-time)

1. Install `mise`, `age`, and `sops`.
2. Generate the age key used to decrypt `secrets.yaml`:
   ```sh
   mkdir -p ~/.age
   age-keygen -o ~/.age/homelab.txt
   chmod 600 ~/.age/homelab.txt
   ```
   See [secret management](../documentation/secret-management.md) for how `secrets.yaml` encryption/editing works day-to-day.
3. Generate an SSH key and copy it to whichever host(s) you're bringing up (skip the one you're not touching yet):
   ```sh
   ssh-keygen -t ed25519 -f ~/.ssh/homelab_admin -C "homelab"
   ssh-copy-id -i ~/.ssh/homelab_admin.pub <user>@<desktop-ip>
   ssh-copy-id -i ~/.ssh/homelab_admin.pub <user>@<nuc-ip>
   ```
4. Add the relevant host(s) to `~/.ssh/config`. The `Host` aliases must match the Ansible inventory hostnames (`homelabdesktop`, `homelabnuc` in `ansible/inventory.yaml`) since Ansible connects by that name with no `ansible_host` override:
   ```
   Host homelabdesktop
     HostName <desktop-ip>
     User gaze
     IdentityFile ~/.ssh/homelab_admin

   Host homelabnuc
     HostName <nuc-ip>
     User gaze
     IdentityFile ~/.ssh/homelab_admin
   ```
5. Copy `.env.example` to `.env` and fill in the values (`HOMELAB_USER`, `HOMELAB_DESKTOP_HOST`, `HOMELAB_NUC_HOST`, etc. — these back `mise run bootstrap`'s Docker contexts, not the SSH config above):
   ```sh
   cp .env.example .env
   ```
6. `mise run bootstrap` — creates the `homelab-desktop` / `homelab-nuc` Docker contexts. Safe to run even if one host is currently off; it only registers the context locally, it doesn't connect.

## Track A — NUC / Kubernetes cluster

The stable core: DNS, a container registry (`registry.home.gaborzeller.com`, separate from the desktop's), Postgres, Jellyfin, monitoring, and the homepage dashboard all run here via k3s. Kubernetes manifests are applied as one batch (Phase A3) rather than resource-by-resource: a Pod that can't pull its image yet just retries (`ImagePullBackOff`) until the dependency shows up, it doesn't block anything else in the same apply. The only hard ordering rule is CRDs/operators before the CRs that use them (that's why CNPG installs before the manifests batch).

### Phase A1 — Host provisioning + NUC infra

1. `mise run ansible:deploy:nuc` — baseline roles (including `docker`, then `homelab`, which creates the `homelab` Docker network needed by `infra-nuc/`) + infra host roles. This is where **k3s actually gets installed** and the kubeconfig is fetched to `~/.kube/homelab-nuc.yaml`.
2. `mise run docker:deploy:infra-nuc` — brings up Technitium DNS.
3. `mise run technitium:bootstrap-api-key`
4. `mise run dns:configure-zone`
5. `mise run dns:configure-blocking` (optional — ad blocking toggle, safe to skip/defer)

At the end of this phase the k3s cluster exists but has nothing deployed to it yet.

### Phase A2 — Kubernetes secrets + operators

6. `mise run verify-cloudflare-tokens` (optional sanity check)
7. `mise run k8s:deploy:secrets` — creates the Cloudflare, Grafana, homepage, and ebay-scraper Secrets in one pass.
   > **Conditional**: the homepage Secret embeds `jellyfin_api_key` from `secrets.yaml`. If Jellyfin's own data (`/srv/jellyfin`) survived the rebuild, the existing key in `secrets.yaml` is still valid and this is a non-issue. If Jellyfin's data was wiped too, this step will embed a stale/empty key — re-run this task after Phase A4 (Jellyfin bootstrap) completes; it's idempotent.
8. `mise run k8s:install-cnpg-operator`

### Phase A3 — Apply all manifests

9. `mise run k8s:deploy:manifests` — Traefik config, Registry, Jellyfin, Postgres Cluster (references the ebay-scraper Secret from step 7), Grafana, homepage, Prometheus, Loki, Alloy, node-exporter, kube-state-metrics, intel-gpu-plugin. Some pods (Postgres, Jellyfin) take a moment to reach Ready.
10. `mise run k8s:bootstrap-postgres-credentials` — once the Postgres cluster is Ready.
11. `mise run k8s:grant-ebay-scraper-privileges` — once the cluster is Ready and the `ebay_scraper` managed role exists.

### Phase A4 — Jellyfin first-run (manual, one-time per fresh Jellyfin volume)

12. **Manual step**: open `https://jellyfin.home.gaborzeller.com`, complete the setup wizard, set the `admin` password to match `jellyfin_admin_password` in `secrets.yaml`. There's no headless way to do this — Jellyfin has no API for first-run setup in this repo's flow.
13. `mise run jellyfin:bootstrap-api-key`
14. `mise run jellyfin:configure`
15. If step 7 ran before this phase, re-run `mise run k8s:deploy:secrets` to pick up the fresh `jellyfin_api_key` into the homepage widget Secret.

## Track B — Desktop / Docker Compose (GPU workloads)

Currently plain Docker Compose, not Kubernetes — Ollama, ComfyUI, sd-scripts, the self-hosted registry, and the custom-image workloads all run here outside k3s. This is expected to move into the cluster eventually; until then, treat this track as independent of Track A and don't assume it needs to run at all for the NUC/k3s side to work.

### Phase B1 — Host provisioning

1. `mise run ansible:deploy:desktop` — baseline roles (including `docker`, then `homelab`, which creates the `homelab` Docker network needed by `infra/` and `services/`) + GPU host roles (NVIDIA driver/toolkit, `/srv/registry` data dir, Docker `insecure-registries` pointed at itself on :5000).

### Phase B2 — Desktop infra (registry) + custom images

2. `mise run docker:deploy:infra` — brings up the self-hosted registry (`$HOMELAB_DESKTOP_HOST:5000`), its UI, glances, dozzle.
3. **Manual/external step**: `services/compose.yaml` references `${HOMELAB_DESKTOP_HOST}:5000/homelab/shadowrun-rag:latest` and `.../sd-scripts:latest` — images built from their own separate source repos. Build and push both **before** the next step, or `docker:deploy:services` will pull-fail on those two containers (ollama, comfyui, and filebrowser use public images and are unaffected). There's no mise task for this build/push yet since the source lives outside this repo.

### Phase B3 — Deploy desktop services

4. `mise run docker:deploy:services` — ollama, shadowrun-rag, comfyui, sd-scripts, filebrowser.

## Day-2 (not part of a rebuild)

- `mise run jellyfin:scan` — after adding new media files (Track A).
- `mise run dns:configure-blocking` — toggle ad blocking anytime (Track A).
