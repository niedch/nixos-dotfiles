#!/usr/bin/env bash

ACTION=$1
CHAR=$3
VALUE=$4

QBIT_HOST="http://dobby:8282"
SECRET_FILE="/run/secrets/qbittorrent/password"
STATE_FILE="/var/lib/homebridge/qbittorrent_download_state"

login() {
  if [ ! -r "$SECRET_FILE" ]; then
    return 1
  fi

  local password
  password=$(cat "$SECRET_FILE")

  COOKIE=$(curl -s -i \
    --header "Referer: $QBIT_HOST" \
    --data-urlencode "username=admin" \
    --data-urlencode "password=$password" \
    "$QBIT_HOST/api/v2/auth/login" 2>/dev/null | grep -i '^set-cookie:' | sed -E 's/^[Ss]et-[Cc]ookie:[[:space:]]*//; s/;.*//' | tr -d '\r\n')

  if [ -z "$COOKIE" ]; then
    return 1
  fi

  return 0
}

fallback() {
  if [ -r "$STATE_FILE" ]; then
    local state
    read -r state < "$STATE_FILE" 2>/dev/null
    state=$(echo "$state" | tr -d '[:space:]')
    if [ "$state" = "0" ] || [ "$state" = "1" ]; then
      echo "$state"
      exit 0
    fi
  fi
  echo "1"
  exit 0
}

if [ "$ACTION" = "Set" ] && [ "$CHAR" = "On" ]; then
  if ! login; then
    exit 1
  fi

  if [ "$VALUE" = "1" ]; then
    curl -s --header "Cookie: $COOKIE" --header "Referer: $QBIT_HOST" --data "hashes=all" "$QBIT_HOST/api/v2/torrents/start" >/dev/null 2>&1
    curl -s --header "Cookie: $COOKIE" --header "Referer: $QBIT_HOST" --data "hashes=all" "$QBIT_HOST/api/v2/torrents/resume" >/dev/null 2>&1
    mkdir -p "$(dirname "$STATE_FILE")" 2>/dev/null
    echo "1" > "$STATE_FILE"
  elif [ "$VALUE" = "0" ]; then
    curl -s --header "Cookie: $COOKIE" --header "Referer: $QBIT_HOST" --data "hashes=all" "$QBIT_HOST/api/v2/torrents/stop" >/dev/null 2>&1
    curl -s --header "Cookie: $COOKIE" --header "Referer: $QBIT_HOST" --data "hashes=all" "$QBIT_HOST/api/v2/torrents/pause" >/dev/null 2>&1
    mkdir -p "$(dirname "$STATE_FILE")" 2>/dev/null
    echo "0" > "$STATE_FILE"
  fi
  exit 0
elif [ "$ACTION" = "Get" ] && [ "$CHAR" = "On" ]; then
  if ! login; then
    fallback
  fi

  torrents=$(curl -s --header "Cookie: $COOKIE" --header "Referer: $QBIT_HOST" "$QBIT_HOST/api/v2/torrents/info" 2>/dev/null)
  if [ $? -ne 0 ] || [ -z "$torrents" ]; then
    fallback
  fi

  if echo "$torrents" | grep -qE '"state"[[:space:]]*:[[:space:]]*"(downloading|metaDL|queuedDL|stalledDL|checkingDL|forcedDL)"'; then
    echo "1"
    mkdir -p "$(dirname "$STATE_FILE")" 2>/dev/null
    echo "1" > "$STATE_FILE"
  elif echo "$torrents" | grep -qE '"state"[[:space:]]*:[[:space:]]*"(stoppedDL|pausedDL)"'; then
    echo "0"
    mkdir -p "$(dirname "$STATE_FILE")" 2>/dev/null
    echo "0" > "$STATE_FILE"
  else
    fallback
  fi
  exit 0
fi
