module "tf_azure_remote_state" {
  source                = "../../modules/terraform_az_remote_state"
  username              = var.username
  environment           = var.environment
  azure_region          = var.azure_region
  azure_subscription_id = var.azure_homelab_subscription_id
}

module "azure_budget" {
  source                = "../../modules//azure_budget"
  environment           = var.environment
  monthly_budget_amount = var.azure_monthly_budget_amount
  azure_admin_email     = var.azure_admin_email
  azure_subscription_id = var.azure_homelab_subscription_id
}
