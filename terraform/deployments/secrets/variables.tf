variable "azure_homelab_subscription_id" {
  description = "The ID of the homelab subscription"
  type        = string
}

variable "azure_region" {
  description = "The azure region"
  type        = string
}

variable "cloudflare_api_token" {
  description = "The cloudflare API token to deploy homelab specific resources"
  type        = string
  sensitive   = true
}
