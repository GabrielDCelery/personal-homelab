ephemeral "random_password" "tunnel" {
  length  = 32
  special = false
}

locals {
  tunnel_secret_version = 1
}

resource "azurerm_key_vault_secret" "tunnel" {
  key_vault_id     = azurerm_key_vault.homelab.id
  name             = "gazelab-cloudflare-tunnel-secret"
  value_wo         = ephemeral.random_password.tunnel.result
  value_wo_version = local.tunnel_secret_version
  depends_on       = [azurerm_key_vault.homelab, azurerm_key_vault_access_policy.homelab]
}

data "azurerm_key_vault_secret" "tunnel" {
  key_vault_id = azurerm_key_vault.homelab.id
  name         = azurerm_key_vault_secret.tunnel.name
  depends_on   = [azurerm_key_vault_secret.tunnel]
}

resource "cloudflare_zero_trust_tunnel_cloudflared" "tunnel" {
  account_id    = var.cloudflare_account_id
  name          = "gazelab-${var.environment}"
  config_src    = "cloudflare"
  tunnel_secret = data.azurerm_key_vault_secret.tunnel.value
  depends_on    = [digitalocean_droplet.homelab]
}

# resource "cloudflare_zero_trust_tunnel_cloudflared_config" "tunnel" {
#   account_id = var.cloudflare_account_id
#   tunnel_id  = resource.cloudflare_zero_trust_tunnel_cloudflared.tunnel.id
# }

data "cloudflare_zero_trust_tunnel_cloudflared_token" "tunnel" {
  account_id = var.cloudflare_account_id
  tunnel_id  = resource.cloudflare_zero_trust_tunnel_cloudflared.tunnel.id
}

resource "cloudflare_zero_trust_tunnel_cloudflared_route" "homelab_server" {
  account_id = var.cloudflare_account_id
  network    = digitalocean_droplet.homelab.ipv4_address
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.tunnel.id
  comment    = "Homelab DigitalOcean Server"
}
