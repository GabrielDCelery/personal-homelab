#!/usr/bin/env bash
set -euo pipefail

USERNAME=$(kubectl get secret homelab-postgres-app -n default -o jsonpath='{.data.username}' | base64 -d)
PASSWORD=$(kubectl get secret homelab-postgres-app -n default -o jsonpath='{.data.password}' | base64 -d)

SECRETS_FILE="$(dirname "$0")/../secrets.yaml"
# --value-stdin keeps the plaintext password out of argv (visible via ps) and shell history.
printf '"%s"' "$USERNAME" | sops set --value-stdin "$SECRETS_FILE" '["postgres_app_user"]'
printf '"%s"' "$PASSWORD" | sops set --value-stdin "$SECRETS_FILE" '["postgres_app_password"]'

echo "postgres_app_user and postgres_app_password updated in secrets.yaml"
