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
}

variable "username" {
  description = "Username all lower characters"
  type        = string
}

variable "environment" {
  description = "The deployment environment"
  type        = string
}

variable "azure_region" {
  description = "The azure region"
  type        = string
}
