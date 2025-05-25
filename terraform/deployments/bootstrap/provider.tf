terraform {
  required_version = ">=1.0.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "tfremstatehomelabgaze"
    storage_account_name = "tfremstatehomelabgaze"
    container_name       = "tfremstatehomelabgaze"
    key                  = "terraform.bootstrap.tfstate"
  }
}

provider "azurerm" {
  subscription_id = var.azure_homelab_subscription_id
  features {}
}
