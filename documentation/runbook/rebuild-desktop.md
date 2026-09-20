# Rebuild Desktop From Scratch

The desktop runs the GPU workloads via plain Docker Compose: Ollama, ComfyUI, sd-scripts, a self-hosted container registry, and custom-image services (`shadowrun-rag`). None of this depends on the NUC at runtime — bring the desktop up, tear it down, or leave it off without affecting the NUC/k3s side. Phases must run in sequence; within a phase, order doesn't matter. Manual/external steps are called out explicitly — everything else is a `mise run` task.

## Phase 0 — Local machine setup

1. Install `mise`, `age`, and `sops`.
2. Generate the age key used to decrypt `secrets.yaml` (skip if already generated while rebuilding another host in this homelab):
   ```sh
   mkdir -p ~/.age
   age-keygen -o ~/.age/homelab.txt
   chmod 600 ~/.age/homelab.txt
   ```
   See [secret management](../secret-management.md) for how `secrets.yaml` encryption/editing works day-to-day.
3. Generate an SSH key (skip if already generated for another host) and copy it to the desktop:
   ```sh
   ssh-keygen -t ed25519 -f ~/.ssh/homelab_admin -C "homelab"
   ssh-copy-id -i ~/.ssh/homelab_admin.pub <user>@<desktop-ip>
   ```
4. Add the desktop to `~/.ssh/config`. The `Host` alias must match the Ansible inventory hostname (`homelabdesktop` in `ansible/inventory.yaml`) since Ansible connects by that name with no `ansible_host` override:
   ```
   Host homelabdesktop
     HostName <desktop-ip>
     User gaze
     IdentityFile ~/.ssh/homelab_admin
   ```
5. Copy `.env.example` to `.env` and fill in the values (`HOMELAB_USER`, `HOMELAB_DESKTOP_HOST`, etc. — these back `mise run bootstrap`'s Docker contexts, not the SSH config above):
   ```sh
   cp .env.example .env
   ```
6. `mise run bootstrap` — creates the `homelab-desktop` Docker context.

## Phase 1 — Host provisioning

1. `mise run ansible:deploy:desktop` — baseline roles (including `docker`, then `homelab`, which creates the `homelab` Docker network needed by `infra/` and `services/`) + GPU host roles (NVIDIA driver/toolkit, `/srv/registry` data dir, Docker `insecure-registries` pointed at itself on :5000).

## Phase 2 — Desktop infra (registry) + custom images

2. `mise run docker:deploy:infra` — brings up the self-hosted registry (`$HOMELAB_DESKTOP_HOST:5000`), its UI, glances, dozzle.
3. **Manual/external step**: `services/compose.yaml` references `${HOMELAB_DESKTOP_HOST}:5000/homelab/shadowrun-rag:latest` and `.../sd-scripts:latest` — images built from their own separate source repos. Build and push both **before** the next step, or `docker:deploy:services` will pull-fail on those two containers (ollama, comfyui, and filebrowser use public images and are unaffected). There's no mise task for this build/push yet since the source lives outside this repo.

## Phase 3 — Deploy desktop services

4. `mise run docker:deploy:services` — ollama, shadowrun-rag, comfyui, sd-scripts, filebrowser.

## Optional — Join the NUC's k3s cluster as a worker node

The desktop can additionally join the NUC's k3s cluster as an agent (worker) node — additive to everything above, the Compose workloads keep running exactly as-is alongside it. Not required for anything in this file. See [desktop-k3s-node.md](desktop-k3s-node.md).
