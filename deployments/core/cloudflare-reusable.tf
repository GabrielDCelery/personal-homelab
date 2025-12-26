# --------------------------------------------------------------------------------------------------------------------------
# Reusable Components
# --------------------------------------------------------------------------------------------------------------------------

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
