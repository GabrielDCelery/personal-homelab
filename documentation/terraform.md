# How to work with the terraform infrastructure

## Pre-requisites

Some of the infrastructure was set up manually to enabling deploying the rest via terraform. These include:

- Azure `Homelab` subscription
- Cloudflare API token roles
  | Resource Type | Permission Scope | Access Level |
  |--------------|------------------|--------------|
  | Account | Zero Trust | Edit |
  | Account | Access: Organizations, Identity Providers and Groups | Edit |
  | Account | Access Apps and Policies | Edit |
  | Zone | DNS | Edit |

## Deployments

- bootstrap
- global
- environments
  - dev
  - test
