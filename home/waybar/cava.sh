#!/usr/bin/env bash
set -u

# Kill leftover processes from previous waybar sessions
for pid in $(pgrep -f "cava.*waybar_cava_config"); do
    [ "$pid" != "$$" ] && kill "$pid" 2>/dev/null
done

bars=(⠀ ⠁ ⠃ ⠇ ⠏ ⠟ ⠿ ⣿)
config_file="/tmp/waybar_cava_config"
fifo="/tmp/waybar_cava_fifo"

cat > "$config_file" <<EOF
[general]
bars = 8
framerate = 30
autosens = 1
reverse = 1

[output]
method = raw
raw_target = /dev/stdout
data_format = ascii
ascii_max_range = 7
channels = mono
mono_option = average
EOF

cleanup() {
    pkill -P $$ 2>/dev/null        # kill children
    kill "$CAVA_PID" 2>/dev/null   # kill cava explicitly
    rm -f "$fifo"
    exit 0
}
trap cleanup EXIT SIGTERM SIGINT

rm -f "$fifo"
mkfifo "$fifo"

cava -p "$config_file" 2>/dev/null > "$fifo" &
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
