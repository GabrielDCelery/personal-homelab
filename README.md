## What is this?

This is the repository storing scripts, documentation and configuration details of my personal homelab.

## How to work with the repo

Have [mise](https://mise.jdx.dev/) for dependency management

```sh
/
├── cloud               # the deployment scripts for the cloud components of my homelab
    ├── bootstrap       # terraform remote state is a chicken and egg this one I used to create the azure blob store
    ├── global          # some core components (e.g. monthly budget) that I don't intend to mess with a lot
    └── homelab         # the actual homelab
├── onprem              # things I want to have automated onprem
├── documentation
└── README.md
```
