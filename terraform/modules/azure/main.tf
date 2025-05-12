data "azurerm_subscription" "homelab_subscription" {
  subscription_id = var.azure_homelab_subscription_id
}

data "azuread_application_published_app_ids" "well_known" {}

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

resource "azuread_service_principal" "msgraph" {
  client_id    = data.azuread_application_published_app_ids.well_known.result.MicrosoftGraph
  use_existing = true
}

resource "azuread_application" "cloudflare_sso" {
  display_name = "Cloudflare SSO"
  web {
    homepage_url  = "https://gaborzeller.cloudflareaccess.com"
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
    resource_app_id = data.azuread_application_published_app_ids.well_known.result.MicrosoftGraph
    # Delegated permissions
    resource_access {
      id   = azuread_service_principal.msgraph.oauth2_permission_scope_ids["User.Read"]
      type = "Scope"
    }
    resource_access {
      id   = azuread_service_principal.msgraph.oauth2_permission_scope_ids["openid"]
      type = "Scope"
    }
    resource_access {
      id   = azuread_service_principal.msgraph.oauth2_permission_scope_ids["email"]
      type = "Scope"
    }
    resource_access {
      id   = azuread_service_principal.msgraph.oauth2_permission_scope_ids["offline_access"]
      type = "Scope"
    }
    resource_access {
      id   = azuread_service_principal.msgraph.oauth2_permission_scope_ids["profile"]
      type = "Scope"
    }
    resource_access {
      id   = azuread_service_principal.msgraph.oauth2_permission_scope_ids["GroupMember.Read.All"]
      type = "Scope"
    }
    resource_access {
      id   = azuread_service_principal.msgraph.oauth2_permission_scope_ids["Directory.Read.All"]
      type = "Scope"
    }
  }
}

resource "azuread_service_principal" "cloudflare_sso" {
  client_id = azuread_application.cloudflare_sso.client_id
}

resource "azuread_service_principal_delegated_permission_grant" "cloudflare_sso" {
  service_principal_object_id          = azuread_service_principal.cloudflare_sso.object_id
  resource_service_principal_object_id = azuread_service_principal.msgraph.object_id
  claim_values = [
    "GroupMember.Read.All",
    "Directory.Read.All"
  ]
}

resource "azuread_application_password" "cloudflare_sso" {
  application_id = azuread_application.cloudflare_sso.id
  display_name   = "Cloudflare SSO Secret"
}

