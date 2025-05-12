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

resource "cloudflare_zero_trust_access_identity_provider" "azure_oauth" {
  config = {
    client_id     = var.azure_sso_app_details.client_id
    client_secret = var.azure_sso_app_details.client_secret
    directory_id  = var.azure_sso_app_details.tenant_id
  }
  # config = {
  #   client_id     = var.azure_sso_app_details.client_id
  #   client_secret = var.azure_sso_app_details.client_secret
  #   directory_id  = var.azure_sso_app_details.tenant_id
  # }
  # account_id = var.cloudflare_account_id
  zone_id = var.cloudflare_zone_id
  name    = "Azure SSO"
  type    = "azureAD"
}
