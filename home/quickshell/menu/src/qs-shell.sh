#!/usr/bin/env bash

# Enable exit on error, error on undefined variables, and propagate pipe failures.
set -euo pipefail

# Clean up quickshell internal crash/nested-instance variables from parent environment 
# to ensure the IPC command runs cleanly.
unset __QUICKSHELL_CRASH_INFO_FD __QUICKSHELL_CRASH_DUMP_PID __QUICKSHELL_CRASH_SIGNAL QS_CONFIG_NAME

# 1. Determine QS_CONFIG_PATH
# If QS_CONFIG_PATH is not already set in the environment, try to detect it from the running quickshell process.
if [[ -z "${QS_CONFIG_PATH:-}" ]]; then
  PID=$(pgrep -x quickshell | head -n1)
  if [[ -n "$PID" && -r "/proc/$PID/environ" ]]; then
    QS_CONFIG_PATH=$(tr '\0' '\n' < "/proc/$PID/environ" | grep '^QS_CONFIG_PATH=' | cut -d= -f2- || true)
  fi
fi

# Fallback paths for local development and standard setups
FALLBACK_PATH="/home/nic/Projects/nixos-dotfiles/home/quickshell/config"
RELATIVE_PATH="./home/quickshell/config"

if [[ -z "${QS_CONFIG_PATH:-}" ]]; then
  if [[ -d "$FALLBACK_PATH" ]]; then
    QS_CONFIG_PATH="$FALLBACK_PATH"
  elif [[ -d "$RELATIVE_PATH" ]]; then
    QS_CONFIG_PATH="$(realpath "$RELATIVE_PATH")"
  else
    QS_CONFIG_PATH="${XDG_CONFIG_HOME:-$HOME/.config}/quickshell"
  fi
fi

export QS_CONFIG_PATH

# 2. Argument preprocessing
# Default the JSON payload to {} for summon/toggle when omitted (matching quickshell-shell behavior)
case "${1:-}" in
  summon|toggle)
    if [[ $# -eq 2 ]]; then
      set -- "$1" "$2" "{}"
    fi
    ;;
esac

# 3. Locate active instance ID if possible
# This ensures we talk to the correct running quickshell instance.
QSID=$(quickshell list --all 2>/dev/null | awk '/^Instance / {gsub(":", "", $2); print $2; exit}' || true)

# 4. Perform the IPC call to quickshell's shell service
if [[ -n "$QSID" ]]; then
  exec quickshell ipc -i "$QSID" call shell "$@" >/dev/null 2>&1 || true
else
  exec quickshell ipc call shell "$@" >/dev/null 2>&1 || true
fi