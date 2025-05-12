variable "cloudflare_account_id" {
  description = "The Cloudflare account id"
  type        = string
}

variable "cloudflare_zone_id" {
  description = "The zone ID for the Cloudflare domain"
  type        = string
}

variable "domain" {
  description = "The domain name"
  type        = string
}

variable "domain_ip" {
  description = "The IP address for the domain's A record"
  type        = string
}

variable "certificate_issuers_allowlist" {
  description = "List of allowed certificate issuers for creating CAA records"
  type = list(object({
    tag   = string
    value = string
  }))
  default = [
    { tag = "issue", value = "digicert.com" },
    # { tag = "issue", value = "pki.goog" },
    # { tag = "issue", value = "sectigo.com" },
    # { tag = "issue", value = "comodoca.com" },
    # { tag = "issue", value = "globalsign.com" },
    # { tag = "issue", value = "letsencrypt.org" },
  ]
}

variable "azure_sso_app_details" {
  description = "Azure SSO app details"
  type = object({
    client_id     = string
    client_secret = string
    tenant_id     = string
  })
}
