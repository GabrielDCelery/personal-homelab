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
    resource_group_name  = "rg-gazelab-glob-tfstate"
    storage_account_name = "stgazelabglobtfstate"
    container_name       = "gazelab-glob-tfstate"
    key                  = "terraform.dev.tfstate"
  }
}

provider "cloudflare" {
  api_token = sensitive(var.cloudflare_api_token)
}

provider "azurerm" {
  subscription_id = var.azure_homelab_subscription_id
  features {}
}
#
# provider "aws" {
#   region = var.aws_region
# }

provider "digitalocean" {
  token = var.digitalocean_token
}
