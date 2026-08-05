#!/usr/bin/env bash
# Aggregates opencode session status files (one file per project) and outputs a
# single-line JSON object consumed by the Quickshell OpenCodeWidget.
set -euo pipefail
shopt -s nullglob

BASE_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/opencode-waybar-status"

files=("$BASE_DIR"/*.json)

if [[ ${#files[@]} -eq 0 ]]; then
  echo '{"state":"none","count":"","tooltip":""}'
  exit 0
fi

working=0
error=0
perm=0
tooltip_lines=()

for f in "${files[@]}"; do
  [[ -f "$f" ]] || continue

  data=$(jq -c . "$f" 2>/dev/null) || continue
  proj=$(basename "$f" .json)

  # Skip stale files (no heartbeat for >20s = session ended)
  updatedAt=$(jq -r '.updatedAt // 0' <<<"$data")
  now=$(date +%s%3N)
  if (( now - updatedAt > 20000 )); then
    continue
  fi

  st=$(jq -r '.status // "idle"' <<<"$data")
  pr=$(jq -r '.permissionRequested // false' <<<"$data")
  tool=$(jq -r '.lastTool // ""' <<<"$data")
  ag=$(jq -r '.agent // ""' <<<"$data")
  mod=$(jq -r '.model // ""' <<<"$data")

  [[ "$st" == "working" ]] && working=$((working + 1))
  [[ "$st" == "error" ]] && error=$((error + 1))
  [[ "$pr" == "true" ]] && perm=$((perm + 1))

  line="$proj: $st"
  [[ -n "$tool" ]] && line+=" (tool: $tool)"
  [[ -n "$ag" ]] && line+=" [agent: $ag]"
  [[ -n "$mod" ]] && line+=" [model: $mod]"
  tooltip_lines+=("$line")
done

# No valid (non-stale) sessions — hide widget entirely
if [[ ${#tooltip_lines[@]} -eq 0 ]]; then
  echo '{"state":"none","count":"","tooltip":""}'
  exit 0
fi

# Determine worst state for icon
worst="idle"
if (( error > 0 )); then
  worst="error"
elif (( perm > 0 )); then
  worst="permission"
elif (( working > 0 )); then
  worst="working"
fi

# Count shows number of working sessions only when at least one is working
count=""
(( working > 0 )) && count="$working"

# Build tooltip: join lines with \n (multiline tooltip)
tooltip=""
if [[ ${#tooltip_lines[@]} -gt 0 ]]; then
  tooltip=$(IFS=$'\n'; printf '%s\n' "${tooltip_lines[@]}")
  tooltip="${tooltip%$'\n'}" # strip trailing newline
fi

# Build JSON output — use jq to properly encode strings
jq -nc --arg state "$worst" --arg count "$count" --arg tooltip "$tooltip" \
  '{state: $state, count: $count, tooltip: $tooltip}'
