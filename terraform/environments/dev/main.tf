module "tf_azure_remote_state" {
  source                = "../../modules/terraform_az_remote_state"
  username              = var.username
  environment           = var.environment
  azure_region          = var.azure_region
  azure_subscription_id = var.azure_homelab_subscription_id
}

