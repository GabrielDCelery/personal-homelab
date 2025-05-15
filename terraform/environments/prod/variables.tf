variable "environment" {
  description = "The deployment environment"
  type        = string
}

variable "azure_homelab_subscription_id" {
  description = "The ID of the homelab subscription"
  type        = string
}

variable "azure_region" {
  description = "The region for the terraform remote state"
  type        = string
}
