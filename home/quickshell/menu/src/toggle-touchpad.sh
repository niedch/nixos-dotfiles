#!/usr/bin/env bash

# Enable exit on error, error on undefined variables, and propagate pipe failures.
set -euo pipefail

STATE_FILE="${XDG_RUNTIME_DIR:-/run/user/1000}/touchpad-disabled"

get_touchpad_devices() {
  hyprctl devices -j | jq -r '(.mice[].name, .keyboards[].name) | select(. | ascii_downcase | contains("touchpad"))' 2>/dev/null | sort -u || true
}

touchpad_on() {
  local devices
  devices=$(get_touchpad_devices)
  if [[ -n "$devices" ]]; then
    while read -r dev; do
      if [[ -n "$dev" ]]; then
        hyprctl keyword "device:$dev:enabled" true >/dev/null 2>&1 || true
      fi
    done <<< "$devices"
  fi
  rm -f "$STATE_FILE"
  omarchy-osd -i "touchpad" -m "Touchpad Enabled"
}

touchpad_off() {
  local devices
  devices=$(get_touchpad_devices)
  if [[ -n "$devices" ]]; then
    while read -r dev; do
      if [[ -n "$dev" ]]; then
        hyprctl keyword "device:$dev:enabled" false >/dev/null 2>&1 || true
      fi
    done <<< "$devices"
  fi
  touch "$STATE_FILE"
  omarchy-osd -i "touchpad" -m "Touchpad Disabled"
}

show_status() {
  if [[ -f "$STATE_FILE" ]]; then
    echo "off"
    exit 1
  else
    echo "on"
    exit 0
  fi
}

case "${1:-}" in
  --status) show_status ;;
  --on)     touchpad_on ;;
  --off)    touchpad_off ;;
  *)
    if [[ -f "$STATE_FILE" ]]; then
      touchpad_on
    else
      touchpad_off
    fi
    ;;
esac
