resource "azurerm_resource_group" "cloudflare" {
  name       = "rg-homelab-cloudflare-glob"
  location   = var.azure_region
  managed_by = var.azure_homelab_subscription_id
}

resource "azurerm_automation_account" "cloudflare" {
  name                = "aa-homelab-cloudflare"
  location            = azurerm_resource_group.cloudflare.location
  resource_group_name = azurerm_resource_group.cloudflare.name
  sku_name            = "Basic"
}

resource "azurerm_automation_variable_string" "cloudflare_policy_superadmin_without_warp" {
  name                    = "cloudflare-policy-superadmin-without-warp-id"
  resource_group_name     = azurerm_resource_group.cloudflare.name
  automation_account_name = azurerm_automation_account.cloudflare.name
  value                   = cloudflare_zero_trust_access_policy.superadmin_without_warp.id
}

resource "azurerm_automation_variable_string" "cloudflare_policy_superadmin_with_warp" {
  name                    = "cloudflare-policy-superadmin-with-warp-id"
  resource_group_name     = azurerm_resource_group.cloudflare.name
  automation_account_name = azurerm_automation_account.cloudflare.name
  value                   = cloudflare_zero_trust_access_policy.superadmin_with_warp.id
}
