variable "azure_admin_email" {
  description = "Admin email for my Azure account"
  type        = string
}

variable "azure_homelab_subscription_id" {
  description = "The ID of the homelab subscription"
  type        = string
}

variable "cloudflare_api_token" {
  description = "The API token used for deployment"
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
