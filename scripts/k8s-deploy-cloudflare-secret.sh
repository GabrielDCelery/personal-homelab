#!/usr/bin/bash

kubectl create secret generic cloudflare-api-token \
  --namespace kube-system \
  --from-literal=apiToken="$cloudflare_api_token" \
  --dry-run=client -o yaml | kubectl apply -f -
