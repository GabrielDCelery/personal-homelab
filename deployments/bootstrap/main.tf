resource "azurerm_resource_group" "tfstate" {
  name       = "rg-homelab-tfstate-glob"
  location   = var.azure_region
  managed_by = var.azure_homelab_subscription_id
}

resource "azurerm_storage_account" "tfstate" {
  name                     = "gazehomelabtfstateglob"
  resource_group_name      = azurerm_resource_group.tfstate.name
  location                 = azurerm_resource_group.tfstate.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "tfstate" {
  name                  = "sc-homelab-tfstate-glob"
  storage_account_id    = azurerm_storage_account.tfstate.id
  container_access_type = "private"
}


