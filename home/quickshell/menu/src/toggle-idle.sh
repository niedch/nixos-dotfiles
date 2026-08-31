#!/usr/bin/env bash

# Enable exit on error, error on undefined variables, and propagate pipe failures.
set -euo pipefail

STATE_FILE="$HOME/.local/state/qs/indicators/stay-awake"

ensure_state_dir() {
  mkdir -p "$(dirname "$STATE_FILE")"
}

is_stay_awake_active() {
  if [[ ! -f "$STATE_FILE" ]]; then
    return 1 # stay-awake inactive (idle rules enabled)
  fi
  local content
  content=$(tr '[:upper:]' '[:lower:]' < "$STATE_FILE" | xargs)
  if [[ "$content" == "true" || "$content" == "on" || "$content" == "1" || "$content" == "" ]]; then
    return 0 # stay-awake active (idle rules disabled)
  else
    return 1 # stay-awake inactive (idle rules enabled)
  fi
}

idle_on() {
  # Enable idle rules (Turn stay-awake OFF)
  ensure_state_dir
  echo "false" > "$STATE_FILE"
  [[ -t 0 ]] || notify-send "Idle" "Idle rules enabled"
}

idle_off() {
  # Disable idle rules (Turn stay-awake ON)
  ensure_state_dir
  echo "true" > "$STATE_FILE"
  [[ -t 0 ]] || notify-send "Idle" "Idle rules disabled"
}

show_status() {
  if is_stay_awake_active; then
    # stay-awake active means idle rules are disabled/off
    echo "off"
    exit 1
  else
    # stay-awake inactive means idle rules are enabled/on
    echo "on"
    exit 0
  fi
}

case "${1:-}" in
  --status) show_status ;;
  --on)     idle_on ;;
  --off)    idle_off ;;
  *)
    if is_stay_awake_active; then
      idle_on
    else
      idle_off
    fi
    ;;
esac
