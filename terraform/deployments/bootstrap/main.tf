resource "azurerm_resource_group" "tf_remote_state" {
  name       = "tfremstatehomelabgaze"
  location   = var.azure_region
  managed_by = var.azure_homelab_subscription_id
}

resource "azurerm_storage_account" "tf_remote_state" {
  name                     = "tfremstatehomelabgaze"
  resource_group_name      = azurerm_resource_group.tf_remote_state.name
  location                 = azurerm_resource_group.tf_remote_state.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "tf_remote_state" {
  name                  = "tfremstatehomelabgaze"
  storage_account_name  = azurerm_storage_account.tf_remote_state.name
  container_access_type = "private"
}


