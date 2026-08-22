#!/usr/bin/env bash
set -euo pipefail

BASE_URL="https://jellyfin.home.gaborzeller.com"
AUTH_HEADER="X-Emby-Token: $jellyfin_api_key"

# Query the actual render device rather than assuming renderD128 - correct on this
# single-GPU NUC by DRM convention, but not guaranteed on other hardware
RENDER_DEVICE=$(ssh "$HOMELAB_USER@$HOMELAB_NUC_HOST" "ls /dev/dri | grep '^render'")
RENDER_DEVICE_PATH="/dev/dri/$RENDER_DEVICE"

# Alternatives depending on GPU vendor: amf (AMD), nvenc (Nvidia), vaapi (generic)
HARDWARE_ACCEL_TYPE="$JELLYFIN_HW_ACCEL_TYPE"

# --- Movies library ---
# AddVirtualFolder isn't an upsert - POSTing a duplicate name errors, so check first for idempotency
EXISTING_FOLDER=$(curl -sS "$BASE_URL/Library/VirtualFolders" -H "$AUTH_HEADER" | jq -r '.[] | select(.Name == "Movies") | .Name')

if [[ -z "$EXISTING_FOLDER" ]]; then
  curl -sS -X POST "$BASE_URL/Library/VirtualFolders?name=Movies&collectionType=movies&refreshLibrary=true" \
    -H "$AUTH_HEADER" \
    -H "Content-Type: application/json" \
    -d '{"LibraryOptions": {"PathInfos": [{"Path": "/media/movies"}], "EnableRealtimeMonitor": true}}' \
    > /dev/null
fi

# --- Hardware acceleration (Intel Quick Sync) ---
# Endpoint expects the full EncodingOptions object, not a partial patch - fetch, modify, POST back whole
CURRENT_ENCODING_CONFIG=$(curl -sS "$BASE_URL/System/Configuration/encoding" -H "$AUTH_HEADER")
UPDATED_ENCODING_CONFIG=$(echo "$CURRENT_ENCODING_CONFIG" | jq \
  --arg device "$RENDER_DEVICE_PATH" \
  --arg accelType "$HARDWARE_ACCEL_TYPE" \
  '.HardwareAccelerationType = $accelType
   | .EnableHardwareEncoding = true
   | .VaapiDevice = $device
   | .QsvDevice = $device')

curl -sS -X POST "$BASE_URL/System/Configuration/encoding" \
  -H "$AUTH_HEADER" \
  -H "Content-Type: application/json" \
  -d "$UPDATED_ENCODING_CONFIG" \
  > /dev/null

# --- Partner user account ---
# Users/New isn't an upsert either - same existence check as the library above
EXISTING_USER=$(curl -sS "$BASE_URL/Users" -H "$AUTH_HEADER" | jq -r --arg name "$jellyfin_partner_username" '.[] | select(.Name == $name) | .Name')

if [[ -z "$EXISTING_USER" ]]; then
  curl -sS -X POST "$BASE_URL/Users/New" \
    -H "$AUTH_HEADER" \
    -H "Content-Type: application/json" \
    -d "{\"Name\": \"$jellyfin_partner_username\", \"Password\": \"$jellyfin_partner_password\"}" \
    > /dev/null
fi
