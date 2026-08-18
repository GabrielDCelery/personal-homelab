#!/usr/bin/env bash
set -euo pipefail

TOKEN=$(curl -sS "http://$HOMELAB_NUC_IP:5380/api/user/login?user=admin&pass=$technitium_admin_password" | jq -r .token)

curl -sS "http://$HOMELAB_NUC_IP:5380/api/settings/set" \
  --data-urlencode "token=$TOKEN" \
  --data-urlencode "enableBlocking=true" \
  --data-urlencode "blockListUrls=https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts,https://big.oisd.nl" \
  > /dev/null

curl -sS "http://$HOMELAB_NUC_IP:5380/api/settings/forceUpdateBlockLists?token=$TOKEN" > /dev/null
