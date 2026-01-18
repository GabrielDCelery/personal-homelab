output "cloudflare_tunnel_token" {
  value     = data.cloudflare_zero_trust_tunnel_cloudflared_token.homelab_tunnel.token
  sensitive = true
}
