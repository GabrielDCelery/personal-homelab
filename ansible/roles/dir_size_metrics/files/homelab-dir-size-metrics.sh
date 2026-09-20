#!/usr/bin/env bash
set -euo pipefail

OUT_DIR="/srv/node-exporter-textfile"
OUT_FILE="${OUT_DIR}/homelab-dir-size.prom"
TMP_FILE="${OUT_FILE}.tmp"

declare -A DIRS=(
  [jellyfin]="/srv/jellyfin"
  [postgresql]="/srv/postgresql"
  [registry]="/srv/registry"
  [ollama-cpu]="/srv/ollama-cpu"
)

{
  echo "# HELP homelab_dir_size_bytes Disk usage of homelab service data directories under /srv"
  echo "# TYPE homelab_dir_size_bytes gauge"
  for service in "${!DIRS[@]}"; do
    dir="${DIRS[$service]}"
    if [ -d "$dir" ]; then
      size=$(du -sb "$dir" | cut -f1)
      echo "homelab_dir_size_bytes{service=\"${service}\"} ${size}"
    fi
  done
} > "$TMP_FILE"

mv "$TMP_FILE" "$OUT_FILE"
