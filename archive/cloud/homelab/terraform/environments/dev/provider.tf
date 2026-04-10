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
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "rg-homelab-tfstate-glob"
    storage_account_name = "gazehomelabtfstateglob"
    container_name       = "sc-homelab-tfstate-glob"
    key                  = "homelab-dev.tfstate"
  }
}

provider "cloudflare" {
  api_token = sensitive(var.cloudflare_api_token)
}

provider "azurerm" {
  subscription_id = var.azure_homelab_subscription_id
  features {}
}

provider "digitalocean" {
  token = sensitive(var.digitalocean_token)
}
