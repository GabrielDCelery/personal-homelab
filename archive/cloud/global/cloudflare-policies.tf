# --------------------------------------------------------------------------------------------------------------------------
# Policies
# --------------------------------------------------------------------------------------------------------------------------

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

