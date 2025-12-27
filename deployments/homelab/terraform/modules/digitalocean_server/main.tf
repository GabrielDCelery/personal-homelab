# -----------------------------------------------------------------
# Azure
# -----------------------------------------------------------------

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "homelab" {
  name       = "rg-homelab-digitalocean-server-${var.environment}"
  location   = var.azure_region
  managed_by = var.azure_homelab_subscription_id
}

resource "azurerm_key_vault" "homelab" {
  name                          = "kv-homleab-do-${var.environment}"
  resource_group_name           = azurerm_resource_group.homelab.name
  location                      = azurerm_resource_group.homelab.location
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  sku_name                      = "standard"
  soft_delete_retention_days    = 90
  purge_protection_enabled      = false
  public_network_access_enabled = true
  depends_on                    = [azurerm_resource_group.homelab]
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
    "List",
    "Delete",
    "Purge",
    "Recover"
  ]
}


# -----------------------------------------------------------------
# SSH keys
# -----------------------------------------------------------------

ephemeral "tls_private_key" "homelab" {
  algorithm   = "ED25519"
  rsa_bits    = 4096
  ecdsa_curve = "P256"
}

locals {
  homelab_digitalocean_server_ssh_key_version = 1
}

resource "azurerm_key_vault_secret" "homelab_private_key" {
  key_vault_id     = azurerm_key_vault.homelab.id
  name             = "homelab-digitalocean-private-key-${var.environment}"
  value_wo         = ephemeral.tls_private_key.homelab.private_key_openssh
  value_wo_version = local.homelab_digitalocean_server_ssh_key_version
  depends_on       = [azurerm_key_vault.homelab, azurerm_key_vault_access_policy.homelab]
}

resource "azurerm_key_vault_secret" "homelab_public_key" {
  key_vault_id     = azurerm_key_vault.homelab.id
  name             = "homelab-digitalocean-public-key-${var.environment}"
  value_wo         = ephemeral.tls_private_key.homelab.public_key_openssh
  value_wo_version = local.homelab_digitalocean_server_ssh_key_version
  depends_on       = [azurerm_key_vault.homelab, azurerm_key_vault_access_policy.homelab]
}

data "azurerm_key_vault_secret" "homelab_public_key" {
  key_vault_id = azurerm_key_vault.homelab.id
  name         = azurerm_key_vault_secret.homelab_public_key.name
  depends_on   = [azurerm_key_vault_secret.homelab_public_key]
}

# -----------------------------------------------------------------
# DigitalOcean droplet
# -----------------------------------------------------------------

resource "digitalocean_ssh_key" "homelab_public_key" {
  name       = "Homelab ${var.environment} public key"
  public_key = data.azurerm_key_vault_secret.homelab_public_key.value
}

locals {
  digitalocean_droplet_environments = {
    dev  = "Development"
    prod = "Production"
  }
}

resource "digitalocean_project" "homelab" {
  name        = "homelab-${var.environment}"
  description = "Development homelab environment"
  environment = local.digitalocean_droplet_environments[var.environment]
  resources   = [digitalocean_droplet.homelab.urn]
}

resource "digitalocean_droplet" "homelab" {
  image    = "ubuntu-24-04-x64"
  name     = "homelab"
  region   = "ams3"
  size     = "s-1vcpu-512mb-10gb"
  backups  = false
  ssh_keys = [digitalocean_ssh_key.homelab_public_key.fingerprint]
}

resource "digitalocean_firewall" "homelab" {
  name = "default"

  droplet_ids = [digitalocean_droplet.homelab.id]

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}

resource "terraform_data" "homelab" {
  depends_on = [digitalocean_droplet.homelab]

  provisioner "local-exec" {
    command = <<EOT
        until nc -zv ${digitalocean_droplet.homelab.ipv4_address} 22; do
          echo "Waiting for SSH..."
          sleep 5
        done
    EOT
  }
}
