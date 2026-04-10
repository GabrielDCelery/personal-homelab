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

### On-prem (Desktop)

```sh
cd onprem
mise install

# for runing ansible
# create ansible.cfg using ansible.cfg.example
cd ansible
ansible-playbook -i inventory.yaml playbook.yaml
# to run tag specific
ansible-playbook -i inventory.yaml playbook.yaml -t git


# for running docker
# create a docker context
docker context create homelab-onprem --docker "host=ssh://username@host"
docker compose -f docker/compose.yaml up -d
```
