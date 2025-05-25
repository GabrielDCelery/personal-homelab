variable "domain_name" {
  type        = string
  description = "Name of the domain"
}

variable "cloudflare_zone_id" {
  type        = string
  description = "Cloudflare zone id"
}

variable "cloudflare_domain_cname_name" {
  type        = string
  description = "cloudflare domain cname name"
}

variable "cloudflare_ipv4_address_ranges" {
  type        = list(string)
  description = "cloudflare ipv4 address ranges"
}

variable "aws_account_id" {
  type        = string
  description = "aws account id"
}
