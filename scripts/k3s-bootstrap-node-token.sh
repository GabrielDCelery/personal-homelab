#!/usr/bin/env bash
set -euo pipefail

NODE_TOKEN=$(ssh -i ~/.ssh/homelab_admin gaze@homelabnuc sudo cat /var/lib/rancher/k3s/server/node-token)

SECRETS_FILE="$(dirname "$0")/../secrets.yaml"
# --value-stdin keeps the plaintext token out of argv (visible via ps) and shell history.
printf '"%s"' "$NODE_TOKEN" | sops set --value-stdin "$SECRETS_FILE" '["k3s_node_token"]'

echo "k3s_node_token updated in secrets.yaml"
