#!/usr/bin/env bash
set -euo pipefail

MODELS=(
  "mxbai-embed-large"
)

POD=$(kubectl get pods -l app=ollama-cpu -o jsonpath='{.items[0].metadata.name}')

for model in "${MODELS[@]}"; do
  echo "Pulling $model into $POD..."
  kubectl exec "$POD" -- ollama pull "$model"
done
