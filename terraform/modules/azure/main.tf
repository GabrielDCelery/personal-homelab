data "azurerm_subscription" "homelab_subscription" {
  subscription_id = var.azure_homelab_subscription_id
}

resource "azurerm_consumption_budget_subscription" "homelab_montly_budget" {
  name            = "homelab_montly_budget"
  subscription_id = data.azurerm_subscription.homelab_subscription.id
  amount          = 20
  time_grain      = "Monthly"
  time_period {
    start_date = "2025-05-01T00:00:00Z"
  }
  notification {
    enabled        = true
    threshold      = 50.0
    operator       = "GreaterThanOrEqualTo"
    contact_emails = [var.azure_admin_email]
  }
}
