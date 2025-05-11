output "homelab_subscription_details" {
  value = {
    id                    = data.azurerm_subscription.homelab_subscription.id
    subscription_id       = data.azurerm_subscription.homelab_subscription.subscription_id
    display_name          = data.azurerm_subscription.homelab_subscription.display_name
    state                 = data.azurerm_subscription.homelab_subscription.state
    location_placement_id = data.azurerm_subscription.homelab_subscription.location_placement_id
    quota_id              = data.azurerm_subscription.homelab_subscription.quota_id
    spending_limit        = data.azurerm_subscription.homelab_subscription.spending_limit
  }
}
