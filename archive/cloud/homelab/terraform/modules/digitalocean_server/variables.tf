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
