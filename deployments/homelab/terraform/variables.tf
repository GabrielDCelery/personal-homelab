# -----------------------------------------------------------------
# Azure
# -----------------------------------------------------------------

variable "azure_homelab_subscription_id" {
  description = "The ID of the homelab subscription"
  type        = string
}

variable "azure_region" {
  description = "The azure region"
  type        = string
}

# -----------------------------------------------------------------
# DigitalOcean 
# -----------------------------------------------------------------

variable "digitalocean_token" {
  type        = string
  description = "The personal access token that is generated via the 'API' section"
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

variable "cloudflare_api_token" {
  type        = string
  description = "This is the token that was set up manually via 'Profile' -> 'API tokens'"
}

variable "cloudflare_admin_email" {
  type        = string
  description = "The admin email for Cloudflare"
}

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
