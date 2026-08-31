#!/usr/bin/env bash

# Enable exit on error, error on undefined variables, and propagate pipe failures.
set -euo pipefail

ON_TEMP=4000
OFF_TEMP=6000

ensure_running() {
  if ! pgrep -x hyprsunset >/dev/null; then
    hyprsunset &
    sleep 1
  fi
}

get_temp() {
  hyprctl hyprsunset temperature 2>/dev/null | grep -oE '[0-9]+' | head -1 || true
}

notify_quickshell() {
  local qsid
  qsid=$(quickshell list --all 2>/dev/null | awk '/^Instance / {gsub(":", "", $2); print $2; exit}' || true)
  if [[ -n "$qsid" ]]; then
    quickshell ipc -i "$qsid" call indicators-refresh refresh >/dev/null 2>&1 || true
  else
    quickshell ipc call indicators-refresh refresh >/dev/null 2>&1 || true
  fi
}

sunset_on() {
  ensure_running
  hyprctl hyprsunset temperature "$ON_TEMP"
  [[ -t 0 ]] || notify-send -u low "󰛨    Blue light filter on (${ON_TEMP}K)"
  notify_quickshell
}

sunset_off() {
  ensure_running
  hyprctl hyprsunset temperature "$OFF_TEMP"
  [[ -t 0 ]] || notify-send -u low "󰛨    Blue light filter off (${OFF_TEMP}K)"
  notify_quickshell
}

show_status() {
  local temp
  temp=$(get_temp)
  if [[ -n "$temp" ]] && [[ "$temp" != "$OFF_TEMP" ]]; then
    echo "on"
    exit 0
  else
    echo "off"
    exit 1
  fi
}

case "${1:-}" in
  --status) show_status ;;
  --on)     sunset_on ;;
  --off)    sunset_off ;;
  *)
    local temp
    temp=$(get_temp)
    if [[ -n "$temp" ]] && [[ "$temp" != "$OFF_TEMP" ]]; then
      sunset_off
    else
      sunset_on
    fi
    ;;
esac
