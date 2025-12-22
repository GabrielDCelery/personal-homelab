## What is this?

This is the repository storing scripts, documentation and configuration details of my personal homelab.

## Project structure

```sh
/
├── archive             # stuff I want to remove but haven't gotten time to properly do it yet
├── deployments         # the deployment scripts for the homelab
    ├── bootstrap       # terraform remote state is a chicken and egg this one I used to create the azure blob store
    ├── core            # some core components (e.g. monthly budget) that I don't intend to mess with a lot
    └── homelab         # the actual homelab
├── documentation
└── README.md
```
