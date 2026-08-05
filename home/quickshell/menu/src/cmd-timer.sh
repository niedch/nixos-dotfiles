#!/usr/bin/env bash

# ── Parse duration to seconds ───────────────────────────────────
parse_duration() {
  local s="$1"
  local total=0

  # Empty input
  [[ -z "$s" ]] && { echo 300; return; }

  # Plain number → treat as minutes
  if [[ "$s" =~ ^[0-9]+\.?[0-9]*$ ]]; then
    awk "BEGIN { printf \"%d\", ${s} * 60 }"
    return
  fi

  while [[ "$s" =~ ([0-9]+\.?[0-9]*)\ *(h|hr|hour|hours|m|min|mins|minute|minutes|s|sec|secs|second|seconds) ]]; do
    local val="${BASH_REMATCH[1]}"
    local unit="${BASH_REMATCH[2]:0:1}"
    s="${s/"${BASH_REMATCH[2]}"/}"
    case "$unit" in
      h) total=$(awk "BEGIN { printf \"%d\", ${total} + ${val} * 3600 }");;
      m) total=$(awk "BEGIN { printf \"%d\", ${total} + ${val} * 60 }");;
      s) total=$(awk "BEGIN { printf \"%d\", ${total} + ${val} }");;
    esac
  done

  if [[ "$total" -le 0 ]]; then
    echo 300
  else
    echo "$total"
  fi
}

# ── Format seconds ──────────────────────────────────────────────
fmt_duration() {
  local s="$1"
  local h=$((s / 3600))
  local m=$(((s % 3600) / 60))
  local sec=$((s % 60))
  local parts=()
  ((h)) && parts+=("${h}h")
  ((m)) && parts+=("${m}m")
  ((sec || ${#parts[@]} == 0)) && parts+=("${sec}s")
  (IFS=" "; echo "${parts[*]}")
}

# ── Main ────────────────────────────────────────────────────────
gum style --bold --foreground 6 "⏱️  Set Timer"
echo

DURATION=$(gum input --placeholder "e.g. 30m, 1h, 90s" --prompt "⏱  " --value "5m")
DESCRIPTION=$(gum input --placeholder "Description (optional)" --prompt "📝 " --value "Time's up!")

DURATION_SECS=$(parse_duration "$DURATION")
TIME_STR=$(fmt_duration "$DURATION_SECS")

echo
gum style --foreground 2 "✓ Timer set for ${TIME_STR} — \"${DESCRIPTION}\""
echo

# Confirm via notification
notify-send "⏱️ Timer Set" "${TIME_STR} — ${DESCRIPTION}" -t 3000

# Schedule via systemd user timer — survives terminal closure
systemd-run --user --on-active="${DURATION_SECS}s" --quiet --collect \
  --setenv=PATH="$PATH" \
  -- notify-send "⏰ Timer Done!" "$DESCRIPTION" -t 10000 -u critical

exit 0
