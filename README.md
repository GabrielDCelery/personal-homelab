# Personal Homelab

Homelab running on a NUC (k3s cluster: DNS, registry, Postgres, Jellyfin, monitoring) and a desktop with an NVIDIA RTX 3060 (GPU workloads via Docker Compose, plus a k3s agent joined to the NUC for monitoring), managed as code.

> The previous cloud deployment (DigitalOcean + k3s + Cloudflare Zero Trust) has been archived under `archive/cloud/`.

## Architecture

- **NUC**: k3s cluster — DNS (Technitium), self-hosted registry, Postgres (CNPG), Jellyfin, Grafana/Prometheus/Loki, homepage dashboard
- **Desktop**: Docker Compose GPU workloads (Ollama, ComfyUI, sd-scripts, custom images) + a k3s agent node for monitoring
- **IaC**: Ansible, Kubernetes manifests, Docker Compose

```
ansible/                    # Host provisioning (Docker, NVIDIA drivers, mise, DNS, k3s)
├── roles/
infra/                      # Desktop infra compose stack (registry, glances, dozzle)
infra-nuc/                  # NUC infra compose stack (Technitium DNS)
k8s/                        # Kubernetes manifests + secrets (NUC k3s cluster)
services/                   # Desktop services compose stack (Ollama, ComfyUI, etc.)
scripts/                    # Task logic invoked by mise (non-trivial tasks)
documentation/              # Hardware specs, network diagrams, runbooks
archive/cloud/              # Archived cloud deployment (DigitalOcean + k3s)
```

## Quick Start

See [documentation/runbook/rebuild-nuc.md](documentation/runbook/rebuild-nuc.md) and [documentation/runbook/rebuild-desktop.md](documentation/runbook/rebuild-desktop.md) for full setup, from a bare machine through the NUC/k3s and desktop/Compose sides respectively — each is self-contained.

All tasks are run from the repo root via `mise run <task>`; see `mise.toml` for the full list.
