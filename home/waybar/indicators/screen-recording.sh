#!/usr/bin/env bash
if pgrep -x wl-screenrec > /dev/null 2>&1; then
  echo '{"text": " REC", "class": "active", "alt": "recording"}'
else
  echo '{"text": "", "class": "", "alt": "idle"}'
fi
sleep 1
