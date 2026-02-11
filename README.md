# Personal Homelab

Hybrid cloud/on-premises homelab infrastructure managed as code. Runs a Kubernetes cluster on DigitalOcean behind Cloudflare Zero Trust, and local GPU-accelerated services on an on-prem desktop.

## Architecture

- **Cloud**: DigitalOcean droplet running k3s, provisioned with Terraform
- **On-prem**: Desktop with NVIDIA RTX 3060 running Docker containers (Ollama, Glances)
- **Networking**: Cloudflare Zero Trust tunnel + Traefik ingress, DNS via Cloudflare
- **Secrets**: Azure Key Vault (SSH keys), Kubernetes Sealed Secrets (tunnel tokens)
- **Monitoring**: Prometheus + Grafana (kube-prometheus-stack), Glances (on-prem)
- **IaC**: Terraform, Ansible, Kubernetes manifests, Helm

```
cloud/
├── bootstrap/              # Terraform remote state (Azure blob store)
├── global/                 # Long-lived resources (budgets, Cloudflare policies, Azure)
└── homelab/
    ├── terraform/          # DigitalOcean droplet + Cloudflare tunnel
    │   ├── environments/dev/
    │   └── modules/
    ├── ansible/            # k3s server provisioning
    └── kubernetes/         # Manifests (Traefik, cloudflared, Homepage, monitoring)
onprem/
├── ansible/                # Desktop provisioning (Docker, NVIDIA drivers, mise)
│   └── roles/
└── docker/                 # Compose file (Ollama, Glances)
documentation/              # Hardware specs, network diagrams
```

## Quick Start

Prerequisites: [mise](https://mise.jdx.dev/), Azure CLI authenticated, Cloudflare API token.

### Cloud (DigitalOcean + k3s)

```sh
cd cloud/homelab
mise install                          # Install Terraform, Ansible, kubectl, Helm, etc.
mise run deploy:full:dev              # Full deployment: Terraform -> Ansible -> k8s
```

This runs the following steps in order:

| Task                  | What it does                                       |
| --------------------- | -------------------------------------------------- |
| `tf:init:dev`         | Initialize Terraform                               |
| `tf:apply:dev`        | Provision DigitalOcean droplet + Cloudflare tunnel |
| `ssh:prepare:dev`     | Fetch SSH key from Azure Key Vault                 |
| `ansible:prepare:dev` | Generate Ansible inventory from Terraform outputs  |
| `ansible:deploy:dev`  | Configure server (k3s, packages)                   |
| `k8s:prepare:dev`     | Fetch kubeconfig, seal Cloudflare tunnel secret    |
| `k8s:deploy:dev`      | Apply all Kubernetes manifests                     |

To tear everything down:

```sh
mise run destroy:full:dev
```

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

## Services

| Service     | Location | Description                        | Access                         |
| ----------- | -------- | ---------------------------------- | ------------------------------ |
| Homepage    | Cloud    | Dashboard for homelab services     | `homepage-dev.gaborzeller.com` |
| Traefik     | Cloud    | Reverse proxy / ingress controller | `traefik-dev.gaborzeller.com`  |
| Prometheus  | Cloud    | Metrics collection                 | In-cluster                     |
| Grafana     | Cloud    | Metrics dashboards                 | In-cluster                     |
| cloudflared | Cloud    | Cloudflare Zero Trust tunnel       | Internal                       |
| Ollama      | On-prem  | LLM inference (GPU-accelerated)    | `localhost:11434`              |
| Glances     | On-prem  | System/GPU monitoring              | Host network                   |

## Configuration

### Cloud tools (managed by `cloud/homelab/mise.toml`)

| Tool      | Version |
| --------- | ------- |
| Terraform | 1.13    |
| Ansible   | 12.1.0  |
| kubectl   | 1.35.0  |
| Helm      | 4.0.4   |
| kubeseal  | 0.34.0  |
| Azure CLI | 2.81.0  |
| Python    | 3.11    |

### On-prem tools (managed by `onprem/mise.toml`)

| Tool    | Version |
| ------- | ------- |
| Ansible | 13.2.0  |

### On-prem Ansible roles

| Role                       | Description                              |
| -------------------------- | ---------------------------------------- |
| `info`                     | Display system information               |
| `docker`                   | Install and configure Docker             |
| `mise`                     | Install mise tool manager                |
| `nvidia_driver`            | Install NVIDIA GPU driver (v580-open)    |
| `nvidia_container_toolkit` | Install NVIDIA Container Toolkit v1.18.2 |
| `homelab`                  | Create Docker volumes for Ollama         |

## Deployment

- **Cloud infra**: Terraform (DigitalOcean droplet, Cloudflare tunnel, Azure Key Vault)
- **Server config**: Ansible (k3s installation, system packages)
- **Applications**: Kubernetes manifests + Helm charts
- **On-prem config**: Ansible (Docker, NVIDIA drivers) + Docker Compose
- **CI/CD**: Manual via `mise run` tasks
- **Environments**: dev
