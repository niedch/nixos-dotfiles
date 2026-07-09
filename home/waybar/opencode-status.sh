#!/usr/bin/env bash
# Aggregates opencode instance status files for this project and outputs a
# single-line JSON object consumed by Waybar's custom module.
shopt -s nullglob
set -euo pipefail

PROJECT_ID="opencode-waybar-status"
RUN_DIR="${XDG_RUNTIME_DIR:-/run/user/${UID:-1000}}/opencode-waybar-status/$PROJECT_ID"

if [[ ! -d "$RUN_DIR" ]] || ! glob=("$RUN_DIR"/*.json) || [[ ${#glob[@]} -eq 0 ]]; then
  echo '{"text":"","alt":"","class":""}'
  exit 0
fi

working=0
error=0
perm=0
tooltip_lines=()

for f in "$RUN_DIR"/*.json; do
  [[ -f "$f" ]] || continue

  data=$(jq -c . "$f" 2>/dev/null) || continue

  # Skip stale files (no heartbeat for >15s = instance is dead)
  updatedAt=$(jq -r '.updatedAt // 0' <<<"$data")
  now=$(date +%s%3N)
  if (( now - updatedAt > 20000 )); then
    continue
  fi

  st=$(jq -r '.status // "idle"' <<<"$data")
  pr=$(jq -r '.permissionRequested // false' <<<"$data")
  inst=$(jq -r '.instanceId // "?"' <<<"$data")
  tool=$(jq -r '.lastTool // ""' <<<"$data")
  ag=$(jq -r '.agent // ""' <<<"$data")
  mod=$(jq -r '.model // ""' <<<"$data")

  [[ "$st" == "working" ]] && working=$((working + 1))
  [[ "$st" == "error" ]] && error=$((error + 1))
  [[ "$pr" == "true" ]] && perm=$((perm + 1))

  line="$inst: $st"
  [[ -n "$tool" ]] && line+=" (tool: $tool)"
  [[ -n "$ag" ]] && line+=" [agent: $ag]"
  [[ -n "$mod" ]] && line+=" [model: $mod]"
  tooltip_lines+=("$line")
done

# No valid (non-stale) instances — hide widget entirely
if [[ ${#tooltip_lines[@]} -eq 0 ]]; then
  echo '{"text":"","alt":"","class":""}'
  exit 0
fi

# Determine worst state for icon/class/alt
worst="idle"
if (( error > 0 )); then
  worst="error"
elif (( perm > 0 )); then
  worst="permission"
elif (( working > 0 )); then
  worst="working"
fi

# Text shows count only when at least one instance is working
text=""
(( working > 0 )) && text="$working"

# Build tooltip: join lines with \r (Waybar convention for multiline)
tooltip=""
if [[ ${#tooltip_lines[@]} -gt 0 ]]; then
  joined=$(IFS=$'\n'; printf '%s\r' "${tooltip_lines[*]}")
  tooltip="${joined%?}"  # strip trailing \r
fi

# Build JSON output — use jq to properly encode strings
jq -nc --arg text "$text" --arg alt "$worst" --arg class "$worst" --arg tooltip "$tooltip" \
  '{text: $text, alt: $alt, class: $class, tooltip: $tooltip}'
