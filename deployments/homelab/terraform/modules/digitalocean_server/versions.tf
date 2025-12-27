terraform {
  required_version = "~> 1.13"
  required_providers {
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.1"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.49"
    }
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.68"
    }
  }
}
