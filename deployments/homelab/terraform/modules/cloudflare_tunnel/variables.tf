# -----------------------------------------------------------------
# Homelab
# -----------------------------------------------------------------

variable "environment" {
  description = "The deployment environment (e.g. dev, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "environment must be one of: 'dev', 'prod'"
  }
}

variable "homelab_server_ipv4" {
  type        = string
  description = "The IP address of the homelab server"
}


# -----------------------------------------------------------------
# Cloudflare
# -----------------------------------------------------------------

variable "cloudflare_zone_name" {
  type        = string
  description = "The name of the cloudflare zone"
}

variable "cloudflare_account_id" {
  type        = string
  description = "The ID that can be found by visiting the 'Account page' then picking the 'domain' (scroll down and is on the right hand side)"
}

variable "cloudflare_zone_id" {
  type        = string
  description = "The ID that can be found by visiting the 'Account page' then picking the 'domain' (scroll down and is on the right hand side)"
}

