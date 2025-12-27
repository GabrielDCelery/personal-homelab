variable "azure_subscription_id" {
  description = "The Azure subscription ID"
  type        = string
}

variable "monthly_budget_name" {
  description = "Name of the monthly budget"
  type        = string
}

variable "monthly_budget_amount" {
  description = "Monthly budget amount"
  type        = number
}

variable "notification_emails" {
  description = "List of email addresses for budget notifications"
  type        = list(string)
}
