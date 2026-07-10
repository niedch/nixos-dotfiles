#!/usr/bin/env bash

ON_TEMP=4000
OFF_TEMP=6000

if ! pgrep -x hyprsunset >/dev/null; then
  hyprsunset &
  sleep 1
fi

CURRENT_TEMP=$(hyprctl hyprsunset temperature 2>/dev/null | grep -oE '[0-9]+')

if [[ "$CURRENT_TEMP" == "$OFF_TEMP" ]]; then
  hyprctl hyprsunset temperature "$ON_TEMP"
  notify-send -u low "󰛨    Blue light filter on (${ON_TEMP}K)"
else
  hyprctl hyprsunset temperature "$OFF_TEMP"
  notify-send -u low "󰛨    Blue light filter off (${OFF_TEMP}K)"
fi
