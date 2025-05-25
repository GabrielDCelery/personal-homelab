terraform {
  required_version = ">=1.0.0"
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.0.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.0.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "tf-rem-state-homelab"
    storage_account_name = "tfremstatehomelabgaze"
    container_name       = "tf-rem-state-container-homelab"
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

provider "aws" {
  region = var.aws_region
}
