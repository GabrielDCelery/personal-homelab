#!/usr/bin/env bash
set -euo pipefail

BASE_URL="https://jellyfin.home.gaborzeller.com"
AUTH_HEADER="X-Emby-Token: $jellyfin_api_key"

curl -sS -X POST "$BASE_URL/Library/Refresh" -H "$AUTH_HEADER" > /dev/null
