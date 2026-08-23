#!/usr/bin/env bash
set -euo pipefail

BASE_URL="https://jellyfin.home.gaborzeller.com"
APP_NAME="homelab-automation"
CLIENT_HEADER='Authorization: MediaBrowser Client="homelab-automation", Device="homelab-automation", DeviceId="homelab-automation", Version="1.0.0"'

# Jellyfin has no "just give me an API key" endpoint - creating one requires
# an authenticated admin session first, so log in as admin to get a session AccessToken.
AUTH_RESPONSE=$(curl -sS -X POST "$BASE_URL/Users/AuthenticateByName" \
  -H "$CLIENT_HEADER" \
  -H "Content-Type: application/json" \
  -d "{\"Username\": \"admin\", \"Pw\": \"$jellyfin_admin_password\"}")

ACCESS_TOKEN=$(echo "$AUTH_RESPONSE" | jq -r '.AccessToken')

if [[ -z "$ACCESS_TOKEN" || "$ACCESS_TOKEN" == "null" ]]; then
  echo "Failed to authenticate as admin against $BASE_URL" >&2
  exit 1
fi

# Subsequent requests authenticate the same way the other Jellyfin scripts do:
# via the long-lived token instead of the session token above.
AUTH_HEADER="X-Emby-Token: $ACCESS_TOKEN"

# API keys aren't scoped/revocable by name lookup alone - check first so re-running this script is idempotent
NEW_KEY=$(curl -sS "$BASE_URL/Auth/Keys" -H "$AUTH_HEADER" | jq -r --arg app "$APP_NAME" '.Items[] | select(.AppName == $app) | .AccessToken' | head -n1)

if [[ -z "$NEW_KEY" ]]; then
  # POST /Auth/Keys creates the key but doesn't return it in the response body -
  # it has to be read back via a second GET /Auth/Keys call.
  curl -sS -X POST "$BASE_URL/Auth/Keys?App=$APP_NAME" -H "$AUTH_HEADER" > /dev/null
  NEW_KEY=$(curl -sS "$BASE_URL/Auth/Keys" -H "$AUTH_HEADER" | jq -r --arg app "$APP_NAME" '.Items[] | select(.AppName == $app) | .AccessToken' | head -n1)
fi

if [[ -z "$NEW_KEY" ]]; then
  echo "Failed to create or retrieve the '$APP_NAME' API key" >&2
  exit 1
fi

SECRETS_FILE="$(dirname "$0")/../secrets.yaml"
# --value-stdin keeps the plaintext key out of argv (visible via ps) and shell history.
printf '"%s"' "$NEW_KEY" | sops set --value-stdin "$SECRETS_FILE" '["jellyfin_api_key"]'

echo "jellyfin_api_key updated in secrets.yaml"
