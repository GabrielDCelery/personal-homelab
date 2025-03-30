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

variable "caa_issuers" {
  description = "List of allowed CAA issuers"
  type = list(object({
    tag   = string
    value = string
  }))
  default = [
    { tag = "issue", value = "pki.goog" },
    { tag = "issue", value = "digicert.com" },
    { tag = "issue", value = "sectigo.com" },
    { tag = "issue", value = "comodoca.com" },
    { tag = "issue", value = "globalsign.com" },
    { tag = "issue", value = "letsencrypt.org" },
  ]
}
