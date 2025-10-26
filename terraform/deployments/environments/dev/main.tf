# module "blog" {
#   source                         = "../../../../blog/infrastructure"
#   domain_name                    = var.domain_name
#   aws_account_id                 = var.aws_account_id
#   cloudflare_zone_id             = var.cloudflare_zone_id
#   cloudflare_domain_cname_name   = var.cloudflare_domain_cname_name
#   cloudflare_ipv4_address_ranges = compact(split("\n", file("${path.module}/files/cloudflare-ipv4-ranges.txt")))
# }
#

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "homelab" {
  name       = "rg-gazelab-${var.environment}-homelab"
  location   = var.azure_region
  managed_by = var.azure_homelab_subscription_id
}

resource "azurerm_key_vault" "homelab" {
  name                          = "kv-gazelab-${var.environment}-secrets"
  resource_group_name           = azurerm_resource_group.homelab.name
  location                      = azurerm_resource_group.homelab.location
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  sku_name                      = "standard"
  soft_delete_retention_days    = 90
  purge_protection_enabled      = false
  public_network_access_enabled = true
}

resource "azurerm_key_vault_access_policy" "homelab" {
  key_vault_id = azurerm_key_vault.homelab.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  key_permissions = [
    "Create",
    "Get",
    "List"
  ]

  secret_permissions = [
    "Delete",
    "Get",
    "List",
    "Purge",
    "Recover",
    "Set",
  ]

  storage_permissions = [
    "Get",
    "List"
  ]
}

ephemeral "tls_private_key" "homelab_digitalocean_server" {
  algorithm   = "ED25519"
  rsa_bits    = 4096
  ecdsa_curve = "P256"
}


locals {
  homelab_digitalocean_server_ssh_key_version = 1
}


resource "azurerm_key_vault_secret" "homelab_digitalocean_server_private_key" {
  key_vault_id     = azurerm_key_vault.homelab.id
  name             = "gazelab-digitalocean-private-key"
  value_wo         = ephemeral.tls_private_key.homelab_digitalocean_server.private_key_openssh
  value_wo_version = local.homelab_digitalocean_server_ssh_key_version
}

resource "azurerm_key_vault_secret" "homelab_digitalocean_server_public_key" {
  key_vault_id     = azurerm_key_vault.homelab.id
  name             = "gazelab-digitalocean-public-key"
  value_wo         = ephemeral.tls_private_key.homelab_digitalocean_server.public_key_openssh
  value_wo_version = local.homelab_digitalocean_server_ssh_key_version
}

data "azurerm_key_vault_secret" "homelab_digitalocean_server_public_key" {
  key_vault_id = azurerm_key_vault.homelab.id
  name         = azurerm_key_vault_secret.homelab_digitalocean_server_public_key.name
  depends_on   = [azurerm_key_vault_secret.homelab_digitalocean_server_public_key]
}

resource "digitalocean_ssh_key" "homelab_digitalocean_server_public_key" {
  name       = "Homelab dev public key"
  public_key = data.azurerm_key_vault_secret.homelab_digitalocean_server_public_key.value
}

resource "digitalocean_droplet" "homelab" {
  image    = "ubuntu-24-04-x64"
  name     = "homelab"
  region   = "ams3"
  size     = "s-1vcpu-512mb-10gb"
  backups  = false
  ssh_keys = [digitalocean_ssh_key.homelab_digitalocean_server_public_key.fingerprint]
}

resource "digitalocean_project" "homelab" {
  name        = "homelab-dev"
  description = "Development homelab environment"
  environment = "Development"
  resources   = [digitalocean_droplet.homelab.urn]
}
