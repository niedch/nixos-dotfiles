#!/usr/bin/env bash

if [[ -f ~/.config/user-dirs.dirs ]]; then
  source ~/.config/user-dirs.dirs
  OUTPUT_DIR="${XDG_PICTURES_DIR:-$HOME/Pictures}"
else
  OUTPUT_DIR="$HOME/Pictures"
fi

if [[ ! -d "$OUTPUT_DIR" ]]; then
  notify-send "Screenshot directory does not exist: $OUTPUT_DIR" -u critical -t 3000
  mkdir -p "$OUTPUT_DIR"
fi

pkill slurp && exit 0
pkill wayfreeze

MODE="${1:-smart}"
DEST="${2:-file}"

get_rectangles() {
  local active_workspace
  active_workspace=$(hyprctl monitors -j | jq -r '.[] | select(.focused == true) | .activeWorkspace.id')

  hyprctl monitors -j | jq -r --arg ws "$active_workspace" '.[] | select(.activeWorkspace.id == ($ws | tonumber)) | "\(.x),\(.y) \((.width / .scale) | floor)x\((.height / .scale) | floor)"'
  hyprctl clients -j | jq -r --arg ws "$active_workspace" '.[] | select(.workspace.id == ($ws | tonumber)) | "\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"'
}

wayfreeze & PID=$!
sleep 0.1

case "$MODE" in
  region)
    SELECTION=$(slurp 2>/dev/null)
    ;;
  windows)
    SELECTION=$(get_rectangles | slurp -r 2>/dev/null)
    ;;
  fullscreen)
    SELECTION=$(hyprctl monitors -j | jq -r '.[] | select(.focused == true) | "\(.x),\(.y) \((.width / .scale) | floor)x\((.height / .scale) | floor)"')
    ;;
  smart|*)
    RECTS=$(get_rectangles)
    SELECTION=$(echo "$RECTS" | slurp 2>/dev/null)

    if [[ "$SELECTION" =~ ^([0-9]+),([0-9]+)[[:space:]]([0-9]+)x([0-9]+)$ ]]; then
      W="${BASH_REMATCH[3]}"
      H="${BASH_REMATCH[4]}"
      AREA=$(( W * H ))

      if (( AREA < 20 )); then
        CLICK_X="${BASH_REMATCH[1]}"
        CLICK_Y="${BASH_REMATCH[2]}"

        while IFS= read -r rect; do
          if [[ "$rect" =~ ^([0-9]+),([0-9]+)[[:space:]]([0-9]+)x([0-9]+) ]]; then
            RX="${BASH_REMATCH[1]}"
            RY="${BASH_REMATCH[2]}"
            RW="${BASH_REMATCH[3]}"
            RH="${BASH_REMATCH[4]}"

            if (( CLICK_X >= RX && CLICK_X < RX+RW && CLICK_Y >= RY && CLICK_Y < RY+RH )); then
              SELECTION="$RX,$RY ${RW}x${RH}"
              break
            fi
          fi
        done <<< "$RECTS"
      fi
    fi
    ;;
esac

kill $PID 2>/dev/null
wait $PID 2>/dev/null
pkill wayfreeze

[ -z "$SELECTION" ] && exit 0

hyprctl dispatch 'hl.dsp.focus({monitor = "+0"})' >/dev/null 2>&1

if [[ "$DEST" == "file" ]]; then
  grim -g "$SELECTION" - | satty --filename -
else
  grim -g "$SELECTION" - | wl-copy
  notify-send "Screenshot copied to clipboard"
fi
