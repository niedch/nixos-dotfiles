#!/usr/bin/env bash

if (($# == 0)); then
  echo "Usage: launch-tui [command] [args...]"
  exit 1
fi

CMD_NAME=$(basename "$1")

exec setsid ghostty --class="org.tui.$CMD_NAME" -- "$@"
