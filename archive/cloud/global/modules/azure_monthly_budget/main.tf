data "azurerm_subscription" "azure_subscription" {
  subscription_id = var.azure_subscription_id
}

resource "azurerm_consumption_budget_subscription" "monthly_budget" {
  name            = var.monthly_budget_name
  subscription_id = data.azurerm_subscription.azure_subscription.id
  amount          = var.monthly_budget_amount
  time_grain      = "Monthly"
  time_period {
    start_date = "2025-12-01T00:00:00Z"
  }
  notification {
    enabled        = true
    threshold      = 50.0
    operator       = "GreaterThanOrEqualTo"
    threshold_type = "Forecasted"
    contact_emails = var.notification_emails
  }
  notification {
    enabled        = true
    threshold      = 100.0
    operator       = "GreaterThanOrEqualTo"
    threshold_type = "Forecasted"
    contact_emails = var.notification_emails
  }
  notification {
    enabled        = true
    threshold      = 100.0
    operator       = "GreaterThanOrEqualTo"
    threshold_type = "Actual"
    contact_emails = var.notification_emails
  }
}
