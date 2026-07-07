#!/usr/bin/env bash

if (($# == 0)); then
  echo "Usage: launch-or-focus-tui [command] [args...]"
  exit 1
fi

CMD_NAME=$(basename "$1")
APP_ID="org.tui.$CMD_NAME"

exec launch-or-focus "$APP_ID" "launch-tui $*"
