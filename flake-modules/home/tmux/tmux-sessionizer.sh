#!/usr/bin/env bash
if command -v mux-session >/dev/null 2>&1; then
  exec mux-session "$@"
elif [ -x /etc/profiles/per-user/nic/bin/mux-session ]; then
  exec /etc/profiles/per-user/nic/bin/mux-session "$@"
else
  echo "mux-session not found in PATH" >&2
  exit 1
fi
