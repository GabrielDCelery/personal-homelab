#!/usr/bin/bash

curl -s -X GET "https://api.cloudflare.com/client/v4/accounts/$cloudflare_account_id/tokens/verify" \
     -H "Authorization: Bearer $cloudflare_api_token" | jq
