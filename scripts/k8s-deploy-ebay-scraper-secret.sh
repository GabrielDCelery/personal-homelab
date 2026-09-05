#!/usr/bin/env bash
set -euo pipefail

SECRETS_FILE="$(dirname "$0")/../secrets.yaml"

if [[ -z "${ebay_scraper_password:-}" ]]; then
  ebay_scraper_password=$(openssl rand -base64 24)
  # --value-stdin keeps the plaintext password out of argv (visible via ps) and shell history.
  printf '"%s"' "$ebay_scraper_password" | sops set --value-stdin "$SECRETS_FILE" '["ebay_scraper_password"]'
  echo "Generated new ebay_scraper_password and stored it in secrets.yaml"
fi

kubectl create secret generic ebay-scraper-password \
  --namespace default \
  --type=kubernetes.io/basic-auth \
  --from-literal=username=ebay_scraper \
  --from-literal=password="$ebay_scraper_password" \
  --dry-run=client -o yaml | kubectl apply -f -
