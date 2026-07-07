#!/usr/bin/env bash

pidof hyprlock || hyprlock &

hyprctl switchxkblayout all 0 > /dev/null 2>&1

if command -v bw &> /dev/null; then
  if bw status | grep -q "unlocked"; then
    bw lock
    notify-send "Vault Locked" "Bitwarden CLI vault has been locked."
  fi
fi
