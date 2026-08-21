#!/usr/bin/bash

kubectl create secret generic grafana-admin-credentials \
  --namespace default \
  --from-literal=user=admin \
  --from-literal=password="$grafana_admin_password" \
  --dry-run=client -o yaml | kubectl apply -f -
