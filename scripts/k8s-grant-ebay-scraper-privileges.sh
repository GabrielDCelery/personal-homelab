#!/usr/bin/env bash
set -euo pipefail

# GRANT statements aren't expressible via CNPG's declarative spec.managed.roles,
# so this stays a one-off script. Re-running it is safe: GRANT doesn't error
# if the privilege is already held.
PRIMARY_POD=$(kubectl get pods -n default -l cnpg.io/cluster=homelab-postgres,role=primary -o jsonpath='{.items[0].metadata.name}')

kubectl exec -n default "$PRIMARY_POD" -c postgres -- psql -U postgres -d app -c \
  "GRANT CREATE ON DATABASE app TO ebay_scraper;"
