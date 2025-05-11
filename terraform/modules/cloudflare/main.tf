# A record for the root domain
resource "cloudflare_dns_record" "root_a" {
  zone_id = var.cloudflare_zone_id
  name    = var.domain
  type    = "A"
  content = var.domain_ip
  proxied = true
  ttl     = 1
}

# CNAME record for the www subdomain
resource "cloudflare_dns_record" "www" {
  zone_id = var.cloudflare_zone_id
  name    = "www"
  type    = "CNAME"
  content = var.domain
  proxied = true
  ttl     = 1
}

# # CAA records for certificate authorities
# resource "cloudflare_record" "caa_records" {
#   for_each = { for idx, issuer in var.certificate_issuers_allowlist : "${issuer.tag}-${issuer.value}" => issuer }
#   zone_id  = var.cloudflare_zone_id
#   name     = var.domain
#   type     = "CAA"
#   proxied  = false
#   ttl      = 1
#   data {
#     flags = 0
#     tag   = each.value.tag
#     value = each.value.value
#   }
# }
#

# resource "cloudflare_access_identity_provider" "azure_oauth" {
#   account_id = var.cloudflare_account_id
#   name       = "Azure SSO"
#   type       = "azure"
#   config {
#     client_id     = azuread_application.cloudflare_sso.application_id
#     client_secret = azuread_application_password.cloudflare_sso.value
#     directory_id  = data.azuread_client_config.current.tenant_id
#   }
# }
