#!/usr/bin/env bash
set -euo pipefail

TOKEN=$(curl -sS "http://$HOMELAB_NUC_IP:5380/api/user/login?user=admin&pass=$technitium_admin_password" | jq -r .token)

curl -sS "http://$HOMELAB_NUC_IP:5380/api/zones/create" \
  --data-urlencode "token=$TOKEN" \
  --data-urlencode "zone=home.gaborzeller.com" \
  --data-urlencode "type=Primary" \
  > /dev/null

curl -sS "http://$HOMELAB_NUC_IP:5380/api/zones/records/add" \
  --data-urlencode "token=$TOKEN" \
  --data-urlencode "zone=home.gaborzeller.com" \
  --data-urlencode "domain=technitium.home.gaborzeller.com" \
  --data-urlencode "type=A" \
  --data-urlencode "ipAddress=$HOMELAB_NUC_IP" \
  --data-urlencode "overwrite=true" \
  > /dev/null
