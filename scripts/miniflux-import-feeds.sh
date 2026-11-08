#!/usr/bin/env bash
set -euo pipefail

BASE_URL="https://miniflux.home.gaborzeller.com"
OPML_FILE="$(dirname "$0")/../k8s/miniflux/feeds.opml"

if [[ -z "${miniflux_api_key:-}" ]]; then
  echo "miniflux_api_key is not set in secrets.yaml, run 'mise run miniflux:bootstrap-api-key' first" >&2
  exit 1
fi

# Safe to re-run: Miniflux skips feed URLs it already has and reuses categories by title,
# so this only adds what's new in the OPML. Feeds removed from the OPML are not deleted.
# The key goes through curl's config on stdin to keep it out of argv (visible via ps).
printf 'header = "X-Auth-Token: %s"\n' "$miniflux_api_key" | curl -sSf -K - \
  -X POST "$BASE_URL/v1/import" \
  -H "Content-Type: application/xml" \
  --data-binary @"$OPML_FILE"
echo

# Import only creates the subscriptions; entries would otherwise wait for the next
# scheduler poll (POLLING_FREQUENCY, 60 minutes by default). This queues a refresh now.
printf 'header = "X-Auth-Token: %s"\n' "$miniflux_api_key" | curl -sSf -K - \
  -X PUT "$BASE_URL/v1/feeds/refresh"
echo "Feed refresh queued, entries appear as each feed is fetched"
