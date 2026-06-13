#!/usr/bin/env bash
while true; do
  if pgrep -x wf-recorder > /dev/null 2>&1; then
    echo '{"text": " REC", "class": "active", "alt": "recording"}'
  else
    echo '{"text": "", "class": "", "alt": "idle"}'
  fi
  sleep 1
done
