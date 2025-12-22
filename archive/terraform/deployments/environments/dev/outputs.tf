output "homelab_do_ipv4" {
  value = digitalocean_droplet.homelab.ipv4_address
}

output "homelab_do_server_private_key" {
  value = {
    vault_name  = azurerm_key_vault.homelab.name
    secret_name = azurerm_key_vault_secret.homelab_digitalocean_server_private_key.name
  }
}

output "ansible_inventory" {
  value = yamlencode({
    homelab = {
      hosts = {
        do_dev = {
          ansible_host = digitalocean_droplet.homelab.ipv4_address
        }
      }
    }
  })
}
