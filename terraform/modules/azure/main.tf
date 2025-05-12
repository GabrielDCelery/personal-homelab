data "azurerm_subscription" "homelab_subscription" {
  subscription_id = var.azure_homelab_subscription_id
}

resource "azurerm_consumption_budget_subscription" "homelab_montly_budget" {
  name            = "homelab_montly_budget"
  subscription_id = data.azurerm_subscription.homelab_subscription.id
  amount          = 20
  time_grain      = "Monthly"
  time_period {
    start_date = "2025-05-01T00:00:00Z"
  }
  notification {
    enabled        = true
    threshold      = 50.0
    operator       = "GreaterThanOrEqualTo"
    contact_emails = [var.azure_admin_email]
  }
}

resource "azuread_application" "cloudflare_sso" {
  display_name = "Cloudflare SSO"
  web {
    # homepage_url  = "https://gaborzeller.cloudflareaccess.com"
    redirect_uris = ["https://gaborzeller.cloudflareaccess.com/cdn-cgi/access/callback"]
  }
  group_membership_claims = ["SecurityGroup"]
  optional_claims {
    id_token {
      name                  = "groups"
      essential             = false
      additional_properties = []
    }
  }

  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000" # Microsoft Graph API ID
    # Delegated permissions
    resource_access {
      id   = "e1fe6dd8-ba31-4d61-89e7-88639da4683d" # User.Read
      type = "Scope"
    }
    resource_access {
      id   = "37f7f235-527c-4136-accd-4a02d197296e" # openid
      type = "Scope"
    }
    resource_access {
      id   = "64a6cdd6-aab1-4aaf-94b8-3cc8405e90d0" # email
      type = "Scope"
    }
    resource_access {
      id   = "7427e0e9-2fba-42fe-b0c0-848c9e6a8182" # offline_access
      type = "Scope"
    }
    resource_access {
      id   = "14dad69e-099b-42c9-810b-d002981feec1" # profile
      type = "Scope"
    }
    resource_access {
      id   = "bc024368-1153-4739-b217-4326f2e966d0" # GroupMember.Read.All
      type = "Scope"
    }
    resource_access {
      id   = "06da0dbc-49e2-44d2-8312-53f166ab848a" # Directory.Read.All
      type = "Scope"
    }
  }
}

resource "azuread_service_principal" "cloudflare_sso" {
  client_id = azuread_application.cloudflare_sso.client_id
}

# resource "azuread_service_principal_delegated_permission_grant" "cloudflare_sso" {
#   service_principal_object_id          = azuread_service_principal.cloudflare_sso.object_id
#   resource_service_principal_object_id = azuread_application.cloudflare_sso.object_id
#   claim_values = [
#     "GroupMember.Read.All",
#     "Directory.Read.All"
#   ]
# }

resource "azuread_application_password" "cloudflare_sso" {
  application_id = azuread_application.cloudflare_sso.id
  display_name   = "Cloudflare SSO Secret"
}

