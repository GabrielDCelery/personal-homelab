# A record for the root domain
resource "cloudflare_record" "root_a" {
  zone_id = var.cloudflare_zone_id
  name    = var.domain
  type    = "A"
  content = var.domain_ip
  proxied = true
  ttl     = 1
}

# CNAME record for the www subdomain
resource "cloudflare_record" "www" {
  zone_id = var.cloudflare_zone_id
  name    = "www"
  type    = "CNAME"
  content = var.domain
  proxied = true
  ttl     = 1
}

# CAA records for certificate authorities
resource "cloudflare_record" "caa_records" {
  for_each = { for idx, issuer in var.caa_issuers : "${issuer.tag}-${issuer.value}" => issuer }
  zone_id  = var.cloudflare_zone_id
  name     = var.domain
  type     = "CAA"
  proxied  = false
  ttl      = 1
  data {
    flags = 0
    tag   = each.value.tag
    value = each.value.value
  }
}

