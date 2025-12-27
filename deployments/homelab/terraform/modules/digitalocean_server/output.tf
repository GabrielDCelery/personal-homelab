output "homelab_server_ipv4" {
  value = digitalocean_droplet.homelab.ipv4_address
}

output "homelab_server_private_key" {
  value = {
    azure_vault_name  = azurerm_key_vault.homelab.name
    azure_secret_name = azurerm_key_vault_secret.homelab_private_key.name
  }
}

output "homelab_server_ansible_inventory" {
  value = yamlencode({
    homelab = {
      hosts = {
        homelab_server = {
          ansible_host = digitalocean_droplet.homelab.ipv4_address
        }
      }
    }
  })
}
