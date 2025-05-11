module "azure" {
  source                        = "./modules/azure"
  azure_homelab_subscription_id = var.azure_homelab_subscription_id
}

module "cloudflare" {
  source             = "./modules/cloudflare"
  domain_ip          = var.domain_ip
  domain             = var.domain
  cloudflare_zone_id = var.cloudflare_zone_id
}
