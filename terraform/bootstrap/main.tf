resource "azurerm_resource_group" "terraform_remote_state_resource_group" {
  name       = "tf-rem-state-homelab"
  location   = var.azure_region
  managed_by = var.azure_homelab_subscription_id
}

resource "azurerm_storage_account" "terraform_remote_state_storage_account" {
  name                     = "tfremstatehomelabgaze"
  resource_group_name      = azurerm_resource_group.terraform_remote_state_resource_group.name
  location                 = azurerm_resource_group.terraform_remote_state_resource_group.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "terraform_remote_state_storage_container" {
  name                  = "tf-rem-state-container-homelab"
  storage_account_name  = azurerm_storage_account.terraform_remote_state_storage_account.name
  container_access_type = "private"
}


