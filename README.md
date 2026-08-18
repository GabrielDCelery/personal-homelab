# Personal Homelab

On-premises homelab running GPU-accelerated services on a desktop, managed as code.

> The previous cloud deployment (DigitalOcean + k3s + Cloudflare Zero Trust) has been archived under `archive/cloud/`.

## Architecture

- **On-prem**: Desktop with NVIDIA RTX 3060 running Docker containers (Ollama, Glances)
- **IaC**: Ansible, Docker Compose

```
ansible/                    # Host provisioning (Docker, NVIDIA drivers, mise, DNS)
├── roles/
infra/                      # Desktop infra compose stack
infra-nuc/                  # NUC infra compose stack (Technitium DNS)
services/                   # Desktop services compose stack (Ollama, Glances)
scripts/                    # Task logic invoked by mise (non-trivial tasks)
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
cp .env.example .env
```

5. Run `mise run bootstrap`

### On-prem (Desktop + NUC)

All tasks are run from the repo root via mise:

| Task                               | Description                                           |
| ---------------------------------- | ------------------------------------------------------ |
| `mise run bootstrap`               | Create Docker contexts for desktop and NUC            |
| `mise run ansible:deploy:desktop`  | Run Ansible playbook against the desktop              |
| `mise run ansible:deploy:nuc`      | Run Ansible playbook against the NUC                  |
| `mise run docker:deploy:infra`     | Deploy desktop infra compose stack                    |
| `mise run docker:deploy:services`  | Deploy desktop services compose stack                 |
| `mise run docker:deploy:infra-nuc` | Deploy NUC infra compose stack                        |
| `mise run dns:configure-blocking`  | Enable ad blocking on the NUC's Technitium DNS server |

For Ansible tag-specific deploys:

```sh
mise run ansible:deploy:desktop git
```
