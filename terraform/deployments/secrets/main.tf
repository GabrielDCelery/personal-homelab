resource "azurerm_resource_group" "secrets" {
  name       = "rg-gazelab-glob-secrets"
  location   = var.azure_region
  managed_by = var.azure_homelab_subscription_id
}

resource "azurerm_key_vault" "secrets" {
  name                          = "kv-gazelab-glob-secrets"
  resource_group_name           = azurerm_resource_group.secrets.name
  location                      = azurerm_resource_group.secrets.location
  tenant_id                     = var.azure_homelab_tenant_id
  sku_name                      = "standard"
  soft_delete_retention_days    = 90
  purge_protection_enabled      = false
  public_network_access_enabled = true
}



