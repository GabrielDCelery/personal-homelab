data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "homelab" {
  name       = "rg-gazelab-${var.environment}-homelab"
  location   = var.azure_region
  managed_by = var.azure_homelab_subscription_id
}

resource "azurerm_key_vault" "homelab" {
  name                          = "kv-gazelab-${var.environment}-secrets"
  resource_group_name           = azurerm_resource_group.homelab.name
  location                      = azurerm_resource_group.homelab.location
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  sku_name                      = "standard"
  soft_delete_retention_days    = 90
  purge_protection_enabled      = false
  public_network_access_enabled = true
  depends_on                    = [azurerm_resource_group.homelab]
}

resource "azurerm_key_vault_access_policy" "homelab" {
  key_vault_id = azurerm_key_vault.homelab.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  key_permissions = [
    "Create",
    "Get",
    "List"
  ]

  secret_permissions = [
    "Delete",
    "Get",
    "List",
    "Purge",
    "Recover",
    "Set",
  ]

  storage_permissions = [
    "Get",
    "List",
    "Delete",
    "Purge",
    "Recover"
  ]
}


