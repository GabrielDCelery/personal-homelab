data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "secrets" {
  name       = "rg-gazelab-glob-secrets"
  location   = var.azure_region
  managed_by = var.azure_homelab_subscription_id
}

resource "azurerm_key_vault" "secrets" {
  name                          = "kv-gazelab-glob-secrets"
  resource_group_name           = azurerm_resource_group.secrets.name
  location                      = azurerm_resource_group.secrets.location
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  sku_name                      = "standard"
  soft_delete_retention_days    = 90
  purge_protection_enabled      = false
  public_network_access_enabled = true
}

resource "azurerm_key_vault_access_policy" "secrets" {
  key_vault_id = azurerm_key_vault.secrets.id
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
    "List"
  ]
}

resource "azurerm_key_vault_secret" "secrets_cloudflare_api_token" {
  name         = "gazelab-cloudflare-api-token"
  value        = var.cloudflare_api_token
  key_vault_id = azurerm_key_vault.secrets.id
}

resource "azurerm_key_vault_secret" "secrets_cloudflare_zone_id" {
  name         = "gazelab-cloudflare-zone-id"
  value        = var.cloudflare_zone_id
  key_vault_id = azurerm_key_vault.secrets.id
}
