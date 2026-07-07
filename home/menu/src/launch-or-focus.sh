#!/usr/bin/env bash

if (($# == 0)); then
  echo "Usage: launch-or-focus [window-pattern] [launch-command]"
  exit 1
fi

WINDOW_PATTERN="$1"
LAUNCH_COMMAND="${2:-"$WINDOW_PATTERN"}"

WINDOW_ADDRESS=$(hyprctl clients -j | jq -r --arg p "$WINDOW_PATTERN" \
  '.[] | select((.class | test($p; "i")) or (.title | test($p; "i"))) | .address' | head -n1)

if [[ -n "$WINDOW_ADDRESS" && "$WINDOW_ADDRESS" != "null" ]]; then
  hyprctl dispatch "hl.dsp.focus({window = \"address:$WINDOW_ADDRESS\"})"
else
  eval exec setsid "$LAUNCH_COMMAND"
fi
