# Personal homelab infrastructure

## What is this?

This is the `terraform` infra of my personal homelab.

## Project structure

```sh
/
├── deployments/        # the actual deployments
│   ├── bootstrap/      # bootstrapping infra
│   ├── environments/   # environment specific deployments
│   └── global          # shared/global deployments
├── modules/            # reusable modules
├── scripts/            # useful scripts
├── Taskfile.yml        # taskfile to manage deployments
└── README.md           # project documentation
```

## Directory Descriptions

### `/deployments/bootstrap`

Infrastructure for managing remote state

> [!WARNING]
> This is responsible for the remote terraform containers, do not touch!

### `/deployments/global`

The infrastructure for deploying globally shared resources across all environments. Examples: `montly budget`, `cloudflare dashboard sso`

### `/deployments/environments`

Environment specific infrastructure

- `/dev`: dev environment
- `/prod`: prod environment

### `/modules`

Reusable environment agnosic terraform modules

### `Taskfile.yml`

Entry point for running deployment related tasks

## Getting started

Have the following installed:

- [Terraform](https://developer.hashicorp.com/terraform)
- [Task](https://taskfile.dev/)

## Usage

```sh
task --list-all
task tf.apply.dev   # deploy dev environment
```
