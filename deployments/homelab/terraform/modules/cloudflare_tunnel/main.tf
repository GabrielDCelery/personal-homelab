# The tunnel managed by Cloudflare 
# Zero Trust -> Network -> Connectors
resource "cloudflare_zero_trust_tunnel_cloudflared" "homelab_tunnel" {
  account_id = var.cloudflare_account_id
  name       = "homelab-${var.environment}"
  config_src = "cloudflare"
}

# The token we need to be able to connect the cloudflared client to the server on Cloudflare
data "cloudflare_zero_trust_tunnel_cloudflared_token" "homelab_tunnel" {
  account_id = var.cloudflare_account_id
  tunnel_id  = resource.cloudflare_zero_trust_tunnel_cloudflared.homelab_tunnel.id
}

# The route to my homelab on DigitalOcean so the tunnel knows how to route the traffic
# Zero Trust -> Network -> Routes
resource "cloudflare_zero_trust_tunnel_cloudflared_route" "homelab_server" {
  account_id = var.cloudflare_account_id
  network    = "${var.homelab_server_ipv4}/32"
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.homelab_tunnel.id
  comment    = "homelab-server-${var.environment}"
}

locals {
  subdomain_map = {
    dev  = "homelab-dev"
    prod = "homelab"
  }
  subdomain   = local.subdomain_map[var.environment]
  full_domain = "${local.subdomain}.${var.cloudflare_zone_name}"
}

# Creates the CNAME record that routes homelab.${var.cloudflare_zone_name} to the tunnel.
resource "cloudflare_dns_record" "http_app" {
  zone_id = var.cloudflare_zone_id
  name    = local.subdomain
  content = "${cloudflare_zero_trust_tunnel_cloudflared.homelab_tunnel.id}.cfargotunnel.com"
  type    = "CNAME"
  ttl     = 1
  proxied = true
}

# Rules on how the tunnel should route the traffic 
# Zero Trust -> Network -> Connectors -> Right hand size three dots 'Configure' -> Published application routes
resource "cloudflare_zero_trust_tunnel_cloudflared_config" "tunnel" {
  account_id = var.cloudflare_account_id
  tunnel_id  = resource.cloudflare_zero_trust_tunnel_cloudflared.homelab_tunnel.id
  config = {
    ingress = [
      {
        hostname = local.full_domain
        service  = "http://reverse_proxy:8080"
      },
      {
        service = "http_status:404"
      }
    ]
  }
}

data "azurerm_automation_variable_string" "cloudflare_policy_superadmin_with_warp" {
  name                    = "cloudflare-policy-superadmin-with-warp-id"
  resource_group_name     = "rg-homelab-cloudflare-glob"
  automation_account_name = "aa-homelab-cloudflare"
}

resource "cloudflare_zero_trust_access_application" "homelab" {
  name       = "app-homelab-${var.environment}"
  account_id = var.cloudflare_account_id
  type       = "self_hosted"
  destinations = [{
    type = "public"
    uri  = local.full_domain
  }]
  policies = [{
    id         = data.azurerm_automation_variable_string.cloudflare_policy_superadmin_with_warp.value
    precedence = 1
  }]
}
