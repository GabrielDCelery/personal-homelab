#!/usr/bin/env bash
set -euo pipefail

# Technitium only returns an API token's value once, at creation - unlike Jellyfin
# there's no way to look an existing token up again, so skip if one's already stored.
if [[ -n "${technitium_api_key:-}" ]]; then
  echo "technitium_api_key already set in secrets.yaml, skipping"
  exit 0
fi

SESSION_TOKEN=$(curl -sS "http://$HOMELAB_NUC_IP:5380/api/user/login?user=admin&pass=$technitium_admin_password" | jq -r .token)

if [[ -z "$SESSION_TOKEN" || "$SESSION_TOKEN" == "null" ]]; then
  echo "Failed to authenticate as admin against Technitium" >&2
  exit 1
fi

NEW_KEY=$(curl -sS "http://$HOMELAB_NUC_IP:5380/api/admin/sessions/createToken" \
  --data-urlencode "token=$SESSION_TOKEN" \
  --data-urlencode "user=admin" \
  --data-urlencode "tokenName=homelab-automation" | jq -r .response.token)

if [[ -z "$NEW_KEY" || "$NEW_KEY" == "null" ]]; then
  echo "Failed to create the 'homelab-automation' API token" >&2
  exit 1
fi

SECRETS_FILE="$(dirname "$0")/../secrets.yaml"
# --value-stdin keeps the plaintext key out of argv (visible via ps) and shell history.
printf '"%s"' "$NEW_KEY" | sops set --value-stdin "$SECRETS_FILE" '["technitium_api_key"]'

echo "technitium_api_key updated in secrets.yaml"
