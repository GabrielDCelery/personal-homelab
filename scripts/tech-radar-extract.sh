#!/usr/bin/env bash
set -euo pipefail

# Pulls the last N days of Miniflux entries per category into generated/tech-radar/<date>/
# as compact markdown extracts for a manual Claude review. No state is kept: the date
# window is the only bookmark, so re-running just overwrites that day's extracts.

BASE_URL="https://miniflux.home.gaborzeller.com"
DAYS="${1:-7}"
SNIPPET_CHARS=500
# High-volume announcement feeds whose titles already say what the entry is. They are
# listed as one line per entry, no snippet, so a week of them stays cheap to skim.
TITLES_ONLY_FEEDS='["https://aws.amazon.com/about-aws/whats-new/recent/feed/"]'

if [[ -z "${miniflux_api_key:-}" ]]; then
  echo "miniflux_api_key is not set in secrets.yaml, run 'mise run miniflux:bootstrap-api-key' first" >&2
  exit 1
fi

NOW=$(date +%s)
# `after` filters on created_at (when Miniflux fetched the entry), so late-fetched posts
# are still caught. `published_after` with an extra week of slack drops archive posts a
# newly added feed dumps in on its first fetch, which all share a fresh created_at.
FETCHED_AFTER=$((NOW - DAYS * 86400))
PUBLISHED_AFTER=$((NOW - (DAYS + 7) * 86400))

OUT_DIR="$(dirname "$0")/../generated/tech-radar/$(date +%Y-%m-%d)"
rm -rf "$OUT_DIR"
mkdir -p "$OUT_DIR"

# The key goes through curl's config on stdin to keep it out of argv (visible via ps).
api_get() {
  printf 'header = "X-Auth-Token: %s"\n' "$miniflux_api_key" | curl -sSf -K - "$BASE_URL$1"
}

WINDOW="$(date -d "@$FETCHED_AFTER" +%Y-%m-%d) to $(date -d "@$NOW" +%Y-%m-%d)"
{
  echo "# Tech radar extracts, $WINDOW"
  echo
  echo "Entries fetched in the last $DAYS days and published in the last $((DAYS + 7))."
  echo "Snippets are the first $SNIPPET_CHARS characters of each entry; open the URL for the full article."
  echo
  echo "| Category | Entries |"
  echo "| -------- | ------- |"
} > "$OUT_DIR/index.md"

api_get "/v1/categories" | jq -r '.[] | "\(.id)\t\(.title)"' | while IFS=$'\t' read -r id title; do
  query="after=$FETCHED_AFTER&published_after=$PUBLISHED_AFTER&order=published_at&direction=desc&limit=1000"
  entries=$(api_get "/v1/categories/$id/entries?$query")

  total=$(jq '.total' <<< "$entries")
  echo "| $title | $total |" >> "$OUT_DIR/index.md"

  {
    echo "# $title, $WINDOW ($total entries)"
    echo
    jq -r --argjson n "$SNIPPET_CHARS" --argjson titles_only "$TITLES_ONLY_FEEDS" '
      .entries
      | (map(select(.feed.feed_url | IN($titles_only[]))) | sort_by(.feed.title)) as $listed
      | (map(select(.feed.feed_url | IN($titles_only[]) | not))) as $full
      | ($full[]
      | (.content
          | gsub("<[^>]*>"; " ")
          | gsub("&nbsp;"; " ") | gsub("&amp;"; "&") | gsub("&lt;"; "<") | gsub("&gt;"; ">")
          | gsub("&quot;"; "\"") | gsub("&#39;"; "'"'"'")
          | gsub("\\s+"; " ")
          | ltrimstr(" ")
          | .[0:$n]) as $snippet
      | "## \(.title)\n\n- \(.feed.title) · \(.published_at[0:10]) · \(.url)\n\n\($snippet)\n"),
        (if ($listed | length) > 0 then
          "## Titles only\n",
          ($listed[] | "- \(.published_at[0:10]) · [\(.title)](\(.url)) · \(.feed.title)"),
          ""
        else empty end)
    ' <<< "$entries"
  } > "$OUT_DIR/$title.md"

  echo "$title: $total entries"
done

echo "Extracts written to $(realpath "$OUT_DIR")"
