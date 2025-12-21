# -----------------------------------------------------------------
# Homelab DigitalOcean server private and public keys
# -----------------------------------------------------------------

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
  depends_on       = [azurerm_key_vault.homelab, azurerm_key_vault_access_policy.homelab]
}

resource "azurerm_key_vault_secret" "homelab_digitalocean_server_public_key" {
  key_vault_id     = azurerm_key_vault.homelab.id
  name             = "gazelab-digitalocean-public-key"
  value_wo         = ephemeral.tls_private_key.homelab_digitalocean_server.public_key_openssh
  value_wo_version = local.homelab_digitalocean_server_ssh_key_version
  depends_on       = [azurerm_key_vault.homelab, azurerm_key_vault_access_policy.homelab]
}

data "azurerm_key_vault_secret" "homelab_digitalocean_server_public_key" {
  key_vault_id = azurerm_key_vault.homelab.id
  name         = azurerm_key_vault_secret.homelab_digitalocean_server_public_key.name
  depends_on   = [azurerm_key_vault_secret.homelab_digitalocean_server_public_key]
}
