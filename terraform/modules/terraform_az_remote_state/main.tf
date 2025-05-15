resource "azurerm_resource_group" "terraform_remote_state_resource_group" {
  name       = "terraform-remote-state-${var.environment}"
  location   = var.azure_region
  managed_by = var.azure_subscription_id
}
