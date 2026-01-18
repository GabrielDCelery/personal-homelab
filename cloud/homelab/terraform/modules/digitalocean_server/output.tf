output "server_ipv4" {
  value = digitalocean_droplet.homelab.ipv4_address
}

output "ssh_key_vault_name" {
  value = azurerm_key_vault.homelab.name
}

output "ssh_key_secret_name" {
  value = azurerm_key_vault_secret.homelab_private_key.name
}

output "ansible_inventory" {
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
