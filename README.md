## What is this?

This is the repository storing scripts, documentation and configuration details of my personal homelab.

## Project structure

```sh
/
├── bootstrap       # some terraform bootstrapping that had to be done first
├── core            # core deplyoment
├── homelab         # the actual homelab
└── README.md       # project summary
```

### bootstrap

Had to run a bootstrapping for terraform, don't intend to rerun it so stays in its own dir

### core

Core deployments that I don't intend to mess with much, like monthly budget settins

### homelab

The actual deployment for homelab

## Project documentation

- [On premise network](./documentation/on-prem-network.md)
- [Homelab specifications](./documentation/homelab-specifications.md)
