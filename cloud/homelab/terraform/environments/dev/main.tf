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
  homelab_server_ipv4   = module.digitalocean_server.server_ipv4
  depends_on            = [module.digitalocean_server]
}

output "server_ipv4" {
  value = module.digitalocean_server.server_ipv4
}

output "ssh_key_vault_name" {
  value = module.digitalocean_server.ssh_key_vault_name
}

output "ssh_key_secret_name" {
  value = module.digitalocean_server.ssh_key_secret_name
}

output "ansible_inventory" {
  value = module.digitalocean_server.ansible_inventory
}

output "cloudflare_tunnel_token" {
  value     = module.cloudflare_tunnel.cloudflare_tunnel_token
  sensitive = true
}
