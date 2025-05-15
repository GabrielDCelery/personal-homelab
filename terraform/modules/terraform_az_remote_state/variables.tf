variable "environment" {
  description = "The deployment environment"
  type        = string
}

variable "azure_subscription_id" {
  description = "The Azure subscription ID"
  type        = string
}

variable "azure_region" {
  description = "The region for the terraform remote state"
  type        = string
}
