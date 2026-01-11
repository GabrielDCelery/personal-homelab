## What is this?

This is the repository storing scripts, documentation and configuration details of my personal homelab.

## Project structure

```sh
/
├── deployments         # the deployment scripts for the homelab
    ├── bootstrap       # terraform remote state is a chicken and egg this one I used to create the azure blob store
    ├── global          # some core components (e.g. monthly budget) that I don't intend to mess with a lot
    └── homelab         # the actual homelab
├── documentation
└── README.md
```
