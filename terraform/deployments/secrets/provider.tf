terraform {
  required_version = ">=1.0.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "rg-gazelab-glob-tfstate"
    storage_account_name = "stgazelabglobtfstate"
    container_name       = "gazelab-glob-tfstate"
    key                  = "secrets.tfstate"
  }
}

provider "azurerm" {
  subscription_id = var.azure_homelab_subscription_id
  features {
    key_vault {
      purge_soft_deleted_secrets_on_destroy = true
      recover_soft_deleted_secrets          = true
    }
  }
}
