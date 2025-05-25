module "azure_budget" {
  source                = "../../modules/azure_monthly_budget"
  notification_emails   = var.azure_budget_notification_emails
  monthly_budget_amount = var.azure_monthly_budget_amount
  azure_subscription_id = var.azure_homelab_subscription_id
}

