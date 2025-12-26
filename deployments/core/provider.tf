terraform {
  required_version = "~> 1.13"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    # azuread = {
    #   source  = "hashicorp/azuread"
    #   version = "~> 3.0.0"
    # }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "rg-gazelab-glob-tfstate"
    storage_account_name = "stgazelabglobtfstate"
    container_name       = "gazelab-glob-tfstate"
    key                  = "common.tfstate"
  }
}

provider "cloudflare" {
  api_token = sensitive(var.cloudflare_api_token)
}

provider "azurerm" {
  subscription_id = var.azure_homelab_subscription_id
  features {}
}
