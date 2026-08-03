#!/usr/bin/env bash

[[ -f ~/.config/user-dirs.dirs ]] && source ~/.config/user-dirs.dirs
OUTPUT_DIR="${XDG_VIDEOS_DIR:-$HOME/Videos}"
STATE_FILE="${XDG_RUNTIME_DIR:-/tmp}/screenrecording"

if [[ ! -d "$OUTPUT_DIR" ]]; then
  notify-send "Screen recording directory does not exist: $OUTPUT_DIR" -u critical -t 3000
  mkdir -p "$OUTPUT_DIR"
fi

DESKTOP_AUDIO="false"
MICROPHONE_AUDIO="false"
STOP_RECORDING="false"

for arg in "$@"; do
  case "$arg" in
    --with-desktop-audio) DESKTOP_AUDIO="true" ;;
    --with-microphone-audio) MICROPHONE_AUDIO="true" ;;
    --stop-recording) STOP_RECORDING="true" ;;
  esac
done

screenrecording_active() {
  [[ -f "$STATE_FILE" ]] && kill -0 "$(cat "$STATE_FILE")" 2>/dev/null
}

start_screenrecording() {
  local filename="$OUTPUT_DIR/screenrecording-$(date +'%Y-%m-%d_%H-%M-%S').mp4"
  local monitor
  monitor=$(hyprctl monitors -j | jq -r '.[] | select(.focused == true) | .name')

  if [[ -z "$monitor" ]]; then
    notify-send "Screen recording error" "Could not determine the focused monitor." -u critical -t 3000
    return 1
  fi

  local audio_args=()
  if [[ "$DESKTOP_AUDIO" == "true" || "$MICROPHONE_AUDIO" == "true" ]]; then
    audio_args+=(--audio)
    if [[ "$MICROPHONE_AUDIO" == "true" ]]; then
      audio_args+=(--audio-device "$(pactl get-default-source)")
    else
      audio_args+=(--audio-device "$(pactl get-default-sink).monitor")
    fi
  fi

  wl-screenrec --output "$monitor" "${audio_args[@]}" --filename "$filename" &
  echo "$!" > "$STATE_FILE"
  notify-send "Screen Recording" "Recording $monitor" -t 3000
}

stop_screenrecording() {
  local pid=""
  [[ -f "$STATE_FILE" ]] && pid=$(cat "$STATE_FILE")

  if [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null; then
    kill -SIGINT "$pid"

    local count=0
    while kill -0 "$pid" 2>/dev/null && [ $count -lt 50 ]; do
      sleep 0.1
      count=$((count + 1))
    done

    if kill -0 "$pid" 2>/dev/null; then
      kill -9 "$pid"
      notify-send "Screen recording error" "Recording process had to be force-killed. Video may be corrupted." -u critical -t 5000
    else
      notify-send "Screen recording saved to $OUTPUT_DIR" -t 2000
    fi
  else
    pkill -SIGINT -x wl-screenrec 2>/dev/null
    notify-send "Screen recording stopped" -t 2000
  fi

  rm -f "$STATE_FILE"
}

if screenrecording_active; then
  stop_screenrecording
elif [[ "$STOP_RECORDING" == "true" ]]; then
  rm -f "$STATE_FILE"
else
  start_screenrecording
fi
