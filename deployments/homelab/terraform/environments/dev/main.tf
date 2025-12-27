module "digitalocean_server" {
  source                        = "../../modules/digitalocean_server"
  environment                   = var.environment
  azure_homelab_subscription_id = var.azure_homelab_subscription_id
  azure_region                  = var.azure_region
}

module "cloudflare_tunnel" {
  source                = "../../modules/cloudflare_tunnel"
  environment           = var.environment
  cloudflare_zone_name  = var.cloudflare_zone_name
  cloudflare_account_id = var.cloudflare_account_id
  cloudflare_zone_id    = var.cloudflare_zone_id
  homelab_server_ipv4   = module.digitalocean_server.homelab_server_ipv4
  depends_on            = [module.digitalocean_server]
}

output "homelab_server_ipv4" {
  value = module.digitalocean_server.homelab_server_ipv4
}

output "homelab_server_private_key" {
  value = module.digitalocean_server.homelab_server_private_key
}

output "homelab_server_ansible_inventory" {
  value = module.digitalocean_server.homelab_server_ansible_inventory
}

output "homelab_server_cloudflare_tunnel_token" {
  value     = module.cloudflare_tunnel.homelab_server_cloudflare_tunnel_token
  sensitive = true
}
