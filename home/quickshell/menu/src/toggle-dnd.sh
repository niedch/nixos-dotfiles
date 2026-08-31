#!/usr/bin/env bash

# Enable exit on error, error on undefined variables, and propagate pipe failures.
set -euo pipefail

get_qsid() {
  quickshell list --all 2>/dev/null | awk '/^Instance / {gsub(":", "", $2); print $2; exit}' || true
}

get_dnd_state() {
  local qsid
  qsid=$(get_qsid)
  local state="false"
  if [[ -n "$qsid" ]]; then
    state=$(quickshell ipc -i "$qsid" call notifications getDnd 2>/dev/null || echo "false")
  else
    state=$(quickshell ipc call notifications getDnd 2>/dev/null || echo "false")
  fi
  echo "$state"
}

notify_toggle() {
  local qsid
  qsid=$(get_qsid)
  if [[ -n "$qsid" ]]; then
    quickshell ipc -i "$qsid" call notifications toggleDnd >/dev/null 2>&1 || true
  else
    quickshell ipc call notifications toggleDnd >/dev/null 2>&1 || true
  fi
}

show_status() {
  local state
  state=$(get_dnd_state)
  if [[ "$state" == "true" ]]; then
    echo "on"
    exit 0
  else
    echo "off"
    exit 1
  fi
}

case "${1:-}" in
  --status) show_status ;;
  *)
    local state
    state=$(get_dnd_state)
    notify_toggle
    
    # Trigger OSD overlay feedback with appropriate icons
    if [[ "$state" == "true" ]]; then
      # DND was true, so now it is false (Off)
      omarchy-osd -i "󰂚" -m "Do Not Disturb: Off"
    else
      # DND was false, so now it is true (On)
      omarchy-osd -i "󰂛" -m "Do Not Disturb: On"
    fi
    ;;
esac
