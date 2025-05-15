variable "azure_admin_email" {
  description = "Admin email for my Azure account"
  type        = string
}

variable "username" {
  description = "Username all lower characters"
  type        = string
}

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

variable "azure_monthly_budget_amount" {
  description = "Monthly Azure budget amount"
  type        = number
}
