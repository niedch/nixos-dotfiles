#!/usr/bin/env bash
set -u

# Kill leftover cava processes from previous quickshell sessions
for pid in $(pgrep -f "cava.*quickshell_cava_config_"); do
    [ "$pid" != "$$" ] && kill "$pid" 2>/dev/null
done

bars=(▁ ▂ ▃ ▄ ▅ ▆ ▇ █)
config_file="/tmp/quickshell_cava_config_$$"
fifo="/tmp/quickshell_cava_fifo_$$"
err_log="/tmp/quickshell_cava_err_$$.log"

# Prefer pipewire input, fall back to pulse (pipewire-pulse compat)
if [ -S "${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/pipewire-0" ] || [ -n "${PIPEWIRE_REMOTE:-}" ]; then
    input_method="pipewire"
else
    input_method="pulse"
fi

cat > "$config_file" <<EOF
[general]
bars = 8
framerate = 30
autosens = 1
reverse = 1

[input]
method = $input_method

[output]
method = raw
raw_target = /dev/stdout
data_format = ascii
ascii_max_range = 7
channels = mono
mono_option = average
EOF

cleanup() {
    pkill -P $$ 2>/dev/null
    kill "$CAVA_PID" 2>/dev/null
    rm -f "$fifo"
    exit 0
}
trap cleanup EXIT SIGTERM SIGINT

rm -f "$fifo"
mkfifo "$fifo"

cava -p "$config_file" 2>"$err_log" > "$fifo" &
CAVA_PID=$!

pause_start=0

convert_to_bars() {
    local line="$1"
    local IFS=';'
    local -a nums
    read -ra nums <<< "$line"
    local out=""
    local n
    for n in "${nums[@]}"; do
        if (( n < 0 || n > 7 )); then
            n=0
        fi
        out+="${bars[n]}"
    done
    printf '%s\n' "$out"
}

is_silence() {
    local l="${1//;/}"
    [[ -z "${l//0/}" ]]
}

while IFS= read -r line || [[ -n "$line" ]]; do
    if is_silence "$line"; then
        if (( pause_start == 0 )); then
            pause_start=$SECONDS
        fi
        if (( SECONDS - pause_start >= 2 )); then
            echo ""
        else
            convert_to_bars "$line"
        fi
        continue
    fi
    pause_start=0
    convert_to_bars "$line"
done < "$fifo"
