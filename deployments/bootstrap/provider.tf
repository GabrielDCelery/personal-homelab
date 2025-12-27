terraform {
  required_version = "~> 1.13"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.49"
    }
  }
  backend "azurerm" {
    resource_group_name  = "rg-homelab-tfstate-glob"
    storage_account_name = "gazehomelabtfstateglob"
    container_name       = "sc-homelab-tfstate-glob"
    key                  = "bootstrap.tfstate"
  }
}

provider "azurerm" {
  subscription_id = var.azure_homelab_subscription_id
  features {}
}
