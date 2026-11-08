#!/usr/bin/env bash
set -euo pipefail

BASE_URL="https://miniflux.home.gaborzeller.com"

# Reuse the existing key if it still authenticates, so re-running this script is idempotent.
if [[ -n "${miniflux_api_key:-}" ]] && \
  curl -sSf -o /dev/null "$BASE_URL/v1/me" -H "X-Auth-Token: $miniflux_api_key"; then
  echo "miniflux_api_key in secrets.yaml is still valid, nothing to do"
  exit 0
fi

# The admin account is created by Miniflux itself on first start (CREATE_ADMIN=1), so
# basic auth as admin works straight away. Credentials go through curl's config on stdin
# to keep the password out of argv (visible via ps). Descriptions must be unique per user,
# hence the timestamp.
NEW_KEY=$(printf 'user = "admin:%s"\n' "$miniflux_admin_password" | curl -sSf -K - \
  -X POST "$BASE_URL/v1/api-keys" \
  -H "Content-Type: application/json" \
  -d "{\"description\": \"homelab-automation-$(date +%Y%m%d%H%M%S)\"}" | jq -r '.token')

if [[ -z "$NEW_KEY" || "$NEW_KEY" == "null" ]]; then
  echo "Failed to create a Miniflux API key against $BASE_URL" >&2
  exit 1
fi

SECRETS_FILE="$(dirname "$0")/../secrets.yaml"
# --value-stdin keeps the plaintext key out of argv (visible via ps) and shell history.
printf '"%s"' "$NEW_KEY" | sops set --value-stdin "$SECRETS_FILE" '["miniflux_api_key"]'

echo "miniflux_api_key updated in secrets.yaml"
