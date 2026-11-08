#!/usr/bin/env bash
set -euo pipefail

SECRETS_FILE="$(dirname "$0")/../secrets.yaml"

# Hex rather than base64: the DB password is embedded in Miniflux's DATABASE_URL,
# where base64's / + = would need URL-encoding.
if [[ -z "${miniflux_db_password:-}" ]]; then
  miniflux_db_password=$(openssl rand -hex 24)
  # --value-stdin keeps the plaintext password out of argv (visible via ps) and shell history.
  printf '"%s"' "$miniflux_db_password" | sops set --value-stdin "$SECRETS_FILE" '["miniflux_db_password"]'
  echo "Generated new miniflux_db_password and stored it in secrets.yaml"
fi

if [[ -z "${miniflux_admin_password:-}" ]]; then
  miniflux_admin_password=$(openssl rand -hex 24)
  printf '"%s"' "$miniflux_admin_password" | sops set --value-stdin "$SECRETS_FILE" '["miniflux_admin_password"]'
  echo "Generated new miniflux_admin_password and stored it in secrets.yaml"
fi

# basic-auth type with username/password keys is what CNPG's managed role passwordSecret expects.
kubectl create secret generic miniflux-db-password \
  --namespace default \
  --type=kubernetes.io/basic-auth \
  --from-literal=username=miniflux \
  --from-literal=password="$miniflux_db_password" \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl create secret generic miniflux-admin-credentials \
  --namespace default \
  --from-literal=password="$miniflux_admin_password" \
  --dry-run=client -o yaml | kubectl apply -f -
