# Desktop k3s Node Setup

This joins `homelabdesktop` to the existing k3s cluster on `homelabnuc` as an agent (worker) node. It's additive to [the desktop rebuild runbook](rebuild-desktop.md) — the desktop keeps running its Docker Compose GPU workloads exactly as before; this just also makes it a schedulable k3s node so DaemonSets (Alloy, node-exporter, kube-state-metrics) pick it up for monitoring.

**Prerequisites** — only these two, not the rest of either runbook:

- [rebuild-nuc.md](rebuild-nuc.md), Phase 1, step 1 only: `mise run ansible:deploy:nuc` has been run (this is what installs the k3s server and creates the node-token; none of the NUC runbook's later phases — DNS, k8s secrets, manifests, Jellyfin — matter here).
- [rebuild-desktop.md](rebuild-desktop.md), Phase 1: `mise run ansible:deploy:desktop` (no tags) has been run at least once, for baseline host setup.

## Steps

1. `mise run k3s:bootstrap-node-token` — SSHes into `homelabnuc`, reads the k3s server's node-token, and writes it into `secrets.yaml` as `k3s_node_token`.
2. `mise run ansible:deploy:desktop k3s_agent` — installs k3s in agent mode on `homelabdesktop` and joins it to `homelabnuc` (`https://<nuc-ip>:6443`), using `k3s_node_token` decrypted from `secrets.yaml`. Fails fast with a clear message if the token is missing/empty (i.e. step 1 wasn't run, or this is invoked without going through `sops exec-env`).
3. **Verify**, from wherever `~/.kube/homelab-nuc.yaml` is your active kubeconfig:
   ```sh
   kubectl get nodes
   ```
   Both `homelabnuc` and `homelabdesktop` should show `Ready`.

## Notes

- The node-token is a cluster admission credential — treat it like a root password. It's stored encrypted in `secrets.yaml` via sops, same as `postgres_app_password` and `jellyfin_api_key`.
- This does **not** migrate the desktop's existing Docker Compose workloads (`ollama`, `comfyui`, `sd-scripts`, `shadowrun-rag`, the registry) into k8s. They keep running as plain containers alongside the new k3s agent process — two separate container-management planes on one box, by design for now.
- No taint/label is applied to the desktop node yet, so in principle any pod could be scheduled there, not just DaemonSets. If that becomes a problem (e.g. a workload landing on the desktop competes with its GPU containers for resources), taint the node and add tolerations only where needed.
