# Personal Homelab

On-premises homelab running GPU-accelerated services on a desktop, managed as code.

> The previous cloud deployment (DigitalOcean + k3s + Cloudflare Zero Trust) has been archived under `archive/cloud/`.

## Architecture

- **On-prem**: Desktop with NVIDIA RTX 3060 running Docker containers (Ollama, Glances)
- **IaC**: Ansible, Docker Compose

```
onprem/
├── ansible/                # Desktop provisioning (Docker, NVIDIA drivers, mise)
│   └── roles/
└── docker/                 # Compose file (Ollama, Glances)
documentation/              # Hardware specs, network diagrams
archive/cloud/              # Archived cloud deployment (DigitalOcean + k3s)
```

## Quick Start

Prerequisites: [mise](https://mise.jdx.dev/).

1. Generate SSH key and copy to homelab:

```sh
ssh-keygen -t ed25519 -f ~/.ssh/homelab_admin -C "homelab"
ssh-copy-id -i ~/.ssh/homelab_admin.pub <homelab-username>@<homelab-ip>
```

2. Add to `~/.ssh/config`:

```
Host homelabdesktop
  HostName <homelab-ip>
  User gaze
  IdentityFile ~/.ssh/homelab_admin
```

3. Copy `.env.example` to `.env` and fill in values:

```sh
cp onprem/.env.example onprem/.env
```

4. Run `mise run bootstrap`

### On-prem (Desktop)

All tasks are run from `onprem/` via mise:

| Task                              | Description                       |
| --------------------------------- | --------------------------------- |
| `mise run bootstrap`              | Create Docker context for homelab |
| `mise run ansible:deploy`         | Run full Ansible playbook         |
| `mise run docker:deploy:infra`    | Deploy infra compose stack        |
| `mise run docker:deploy:services` | Deploy services compose stack     |

For Ansible tag-specific deploys:

```sh
mise run ansible:deploy -- -t git
```
