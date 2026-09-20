#!/usr/bin/env bash
set -euo pipefail

curl -sS -X POST https://starwars-armada.home.gaborzeller.com/admin/refresh
echo

echo "Started (or already running). Follow progress with:"
echo "  kubectl logs -l app=starwars-armada -f"
