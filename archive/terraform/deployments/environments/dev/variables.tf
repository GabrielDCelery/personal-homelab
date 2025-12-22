# variable "username" {
#   description = "Username all lower characters"
#   type        = string
# }

#
# variable "azure_homelab_subscription_id" {
#   description = "The ID of the homelab subscription"
#   type        = string
# }
#
# variable "azure_region" {
#   description = "The Azure region"
#   type        = string
# }
#
# variable "aws_account_id" {
#   description = "AWS account ID"
#   type        = string
# }
#
# variable "aws_region" {
#   description = "The AWS region"
#   type        = string
# }
#
# variable "domain_name" {
#   description = "personal blog domain name"
#   type        = string
# }
#
# variable "cloudflare_api_token" {
#   description = "cloudlflare api token"
#   type        = string
#   sensitive   = true
# }
#
# variable "cloudflare_zone_id" {
#   description = "cloudflare zone id"
#   type        = string
# }
#
# variable "cloudflare_domain_cname_name" {
#   type        = string
#   description = "cloudflare domain cname name"
# }
#
variable "digitalocean_token" {
  type        = string
  description = "DigitalOcean token"
}

variable "azure_homelab_subscription_id" {
  description = "The ID of the homelab subscription"
  type        = string
}

variable "azure_region" {
  description = "The azure region"
  type        = string
}

variable "environment" {
  description = "The deployment environment"
  type        = string
}
