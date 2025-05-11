module "azure" {
  source = "./modules/azure"
}

module "cloudflare" {
  source             = "./modules/cloudflare"
  domain_ip          = var.domain_ip
  domain             = var.domain
  cloudflare_zone_id = var.cloudflare_zone_id
}
