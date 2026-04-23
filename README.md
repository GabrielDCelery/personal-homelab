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

Prerequisites:

- [mise](https://mise.jdx.dev/)
- [age](https://github.com/FiloSottile/age)
- [sops](https://github.com/getsops/sops).

1. Generate age key for secrets decryption (once per machine):

```sh
mkdir -p ~/.age
# note the public key after generating the homelab.txt
age-keygen -o ~/.age/homelab.txt
chmod 600 ~/.age/homelab.txt
```

See [secret management](documentation/secret-management.md) for how to encrypt, edit, and use secrets.

2. Generate SSH key and copy to homelab:

```sh
ssh-keygen -t ed25519 -f ~/.ssh/homelab_admin -C "homelab"
ssh-copy-id -i ~/.ssh/homelab_admin.pub <homelab-username>@<homelab-ip>
```

3. Add to `~/.ssh/config`:

```
Host homelabdesktop
  HostName <homelab-ip>
  User gaze
  IdentityFile ~/.ssh/homelab_admin
```

4. Copy `.env.example` to `.env` and fill in values:

```sh
cp onprem/.env.example onprem/.env
```

5. Run `cd onprem && mise run bootstrap`

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
