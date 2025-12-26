# The tunnel managed by Cloudflare 
# Zero Trust -> Network -> Connectors
resource "cloudflare_zero_trust_tunnel_cloudflared" "tunnel" {
  account_id = var.cloudflare_account_id
  name       = "gazelab-${var.environment}"
  config_src = "cloudflare"
  depends_on = [digitalocean_droplet.homelab]
}

# The token we need to be able to connect the cloudflared client to the server on Cloudflare
data "cloudflare_zero_trust_tunnel_cloudflared_token" "tunnel" {
  account_id = var.cloudflare_account_id
  tunnel_id  = resource.cloudflare_zero_trust_tunnel_cloudflared.tunnel.id
}

# The route to my homelab on DigitalOcean so the tunnel knows how to route the traffic
# Zero Trust -> Network -> Routes
resource "cloudflare_zero_trust_tunnel_cloudflared_route" "homelab_server" {
  account_id = var.cloudflare_account_id
  network    = "${digitalocean_droplet.homelab.ipv4_address}/32"
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.tunnel.id
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
  content = "${cloudflare_zero_trust_tunnel_cloudflared.tunnel.id}.cfargotunnel.com"
  type    = "CNAME"
  ttl     = 1
  proxied = true
}


# Rules on how the tunnel should route the traffic 
# Zero Trust -> Network -> Connectors -> Right hand size three dots 'Configure' -> Published application routes
resource "cloudflare_zero_trust_tunnel_cloudflared_config" "tunnel" {
  account_id = var.cloudflare_account_id
  tunnel_id  = resource.cloudflare_zero_trust_tunnel_cloudflared.tunnel.id
  config = {
    ingress = [
      {
        hostname = local.full_domain
        service  = "http://reverse_proxy:80"
      },
      {
        service = "http_status:404"
      }
    ]
  }
}

# This is a reusable component for WARP client checks
# Zero Trust -> Reusable components -> Posture checks
resource "cloudflare_zero_trust_device_posture_rule" "warp_required" {
  account_id = var.cloudflare_account_id
  name       = "WARP Required"
  type       = "warp"
  lifecycle {
    ignore_changes = [description]
  }
}

resource "cloudflare_zero_trust_access_policy" "homelab_superadmin" {
  account_id = var.cloudflare_account_id
  decision   = "allow"
  name       = "superadmin"
  include = [{
    email = {
      email = var.cloudflare_admin_email
    }
  }]
  require = [{
    device_posture = {
      integration_uid = cloudflare_zero_trust_device_posture_rule.warp_required.id
    }
  }]
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
    id         = cloudflare_zero_trust_access_policy.homelab_superadmin.id
    precedence = 1
  }]
}

resource "cloudflare_zero_trust_device_custom_profile" "superadmin" {
  name       = "dp-homelab-superadmin-${var.environment}"
  precedence = 1
  match      = "identity.email == \"${var.cloudflare_admin_email}\""
  account_id = var.cloudflare_account_id
  lifecycle {
    ignore_changes = [description, include]
  }
}

resource "cloudflare_zero_trust_access_application" "app_launcher" {
  account_id = var.cloudflare_account_id
  type       = "app_launcher"
  policies = [{
    id         = cloudflare_zero_trust_access_policy.homelab_superadmin.id
    precedence = 1
  }]
}

resource "cloudflare_zero_trust_access_application" "warp" {
  account_id = var.cloudflare_account_id
  type       = "warp"
  policies = [{
    id         = cloudflare_zero_trust_access_policy.homelab_superadmin.id
    precedence = 1
  }]
}

