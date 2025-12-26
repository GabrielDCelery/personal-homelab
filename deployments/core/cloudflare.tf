# This is a reusable component for WARP client checks
# Zero Trust -> Reusable components -> Posture checks
resource "cloudflare_zero_trust_device_posture_rule" "warp_required" {
  account_id = var.cloudflare_account_id
  name       = "WARP Required"
  type       = "warp"
  lifecycle {
    ignore_changes = [description]
  }
}

resource "cloudflare_zero_trust_access_policy" "superadmin_without_warp" {
  account_id = var.cloudflare_account_id
  decision   = "allow"
  name       = "superadmin_without_warp"
  include = [{
    email = {
      email = var.cloudflare_superadmin_email
    }
  }]
}

resource "cloudflare_zero_trust_access_policy" "superadmin_with_warp" {
  account_id = var.cloudflare_account_id
  decision   = "allow"
  name       = "superadmin_with_warp"
  include = [{
    email = {
      email = var.cloudflare_superadmin_email
    }
  }]
  require = [{
    device_posture = {
      integration_uid = cloudflare_zero_trust_device_posture_rule.warp_required.id
    }
  }]
}


# This creates an app that allows to connect to the team's application dashboard
# This is NOT shown in the Zero Trust -> Access Control -> Applications section but rather under
# Zero Trust -> Access Control -> Access Settings 
resource "cloudflare_zero_trust_access_application" "app_launcher" {
  account_id = var.cloudflare_account_id
  type       = "app_launcher"
  landing_page_design = {
    title = "Welcome!"
  }
  policies = [{
    id         = cloudflare_zero_trust_access_policy.superadmin_with_warp.id
    precedence = 1
  }]
}


# This creates an app that allows to connect to the team's account using WARP
# This is NOT shown in the Zero Trust -> Access Control -> Applications section but rather under
# Zero Trust -> Teams & Resources -> Devices -> Management -> Device Enrollment Permissions (and then clicking on the permission and viewing the associated applications)
resource "cloudflare_zero_trust_access_application" "warp" {
  account_id = var.cloudflare_account_id
  type       = "warp"
  policies = [{
    id         = cloudflare_zero_trust_access_policy.superadmin_without_warp.id # when trying to use a policy that enforced WARP it was not working
    precedence = 1
  }]
}

