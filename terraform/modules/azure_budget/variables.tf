variable "azure_admin_email" {
  description = "Admin email for my Azure account"
  type        = string
}


variable "environment" {
  description = "The deployment environment"
  type        = string
}

variable "azure_subscription_id" {
  description = "The Azure subscription ID"
  type        = string
}

variable "monthly_budget_amount" {
  description = "Monthly budget amount"
  type        = number
}
