resource "azurerm_resource_group" "terraform_remote_state_resource_group" {
  name       = "terraform-remote-state-${var.environment}"
  location   = var.azure_region
  managed_by = var.azure_subscription_id
}

resource "azurerm_storage_account" "terraform_remote_state_storage_account" {
  name                     = "tfremotestate${var.username}${var.environment}"
  resource_group_name      = azurerm_resource_group.terraform_remote_state_resource_group.name
  location                 = azurerm_resource_group.terraform_remote_state_resource_group.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
