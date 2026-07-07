#!/usr/bin/env bash

hyprctl clients -j | jq -r ".[].address" | xargs -r -I{} hyprctl dispatch "hl.dsp.window.close({window = \"address:{}\"})"
sleep 1
systemctl reboot
