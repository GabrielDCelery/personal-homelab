# -----------------------------------------------------------------
# DigitalOcean droplet
# -----------------------------------------------------------------

resource "digitalocean_ssh_key" "homelab_digitalocean_server_public_key" {
  name       = "Homelab dev public key"
  public_key = data.azurerm_key_vault_secret.homelab_digitalocean_server_public_key.value
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
  ssh_keys = [digitalocean_ssh_key.homelab_digitalocean_server_public_key.fingerprint]
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
