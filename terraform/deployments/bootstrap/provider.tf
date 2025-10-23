terraform {
  required_version = ">=1.0.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "rg-gazelab-glob-tfstate"
    storage_account_name = "stgazelabglobtfstate"
    container_name       = "gazelab-glob-tfstate"
    key                  = "bootstrap.tfstate"
  }
}

provider "azurerm" {
  subscription_id = var.azure_homelab_subscription_id
  features {}
}
