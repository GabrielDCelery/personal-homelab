# --------------------------------------------------------------------------------------------------------------------------
# Azure
# --------------------------------------------------------------------------------------------------------------------------

variable "azure_homelab_subscription_id" {
  description = "The ID of the homelab subscription"
  type        = string
}

variable "azure_monthly_budget_amount" {
  description = "Monthly Azure budget amount"
  type        = number
}

variable "azure_budget_notification_emails" {
  description = "List of email addresses for budget notifications"
  type        = list(string)
  sensitive   = true
}

variable "azure_region" {
  description = "The azure region"
  type        = string
}

# --------------------------------------------------------------------------------------------------------------------------
# Cloudflare
# --------------------------------------------------------------------------------------------------------------------------


variable "cloudflare_account_id" {
  type        = string
  description = "The ID that can be found by visiting the 'Account page' then picking the 'domain' (scroll down and is on the right hand side)"
  sensitive   = true
}

variable "cloudflare_api_token" {
  type        = string
  description = "This is the token that was set up manually via 'Profile' -> 'API tokens'"
  sensitive   = true
}

variable "cloudflare_superadmin_email" {
  description = "Email of the super admin on Cloudflare"
  type        = string
  sensitive   = true
}
