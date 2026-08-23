#!/usr/bin/bash

kubectl create secret generic homepage-credentials \
  --namespace default \
  --from-literal=jellyfinApiKey="$jellyfin_api_key" \
  --from-literal=technitiumApiKey="$technitium_api_key" \
  --dry-run=client -o yaml | kubectl apply -f -
