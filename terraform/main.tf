# module "azure" {
#   source                        = "./modules/azure"
#   azure_homelab_subscription_id = var.azure_homelab_subscription_id
#   azure_admin_email             = var.azure_admin_email
# }
#
# module "cloudflare" {
#   source                = "./modules/cloudflare"
#   domain_ip             = var.domain_ip
#   domain                = var.domain
#   cloudflare_account_id = var.cloudflare_account_id
#   cloudflare_zone_id    = var.cloudflare_zone_id
#   azure_sso_app_details = module.azure.azure_sso_app_details
# }

# output "azure_homelab_subscription_details" {
#   value = module.azure.homelab_subscription_details
# }
#
