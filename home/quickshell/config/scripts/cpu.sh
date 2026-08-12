#!/usr/bin/env bash
set -u

state_file="${XDG_RUNTIME_DIR:-/tmp}/cpu-usage-state"

# Read current CPU totals from /proc/stat
read -r t_now i_now <<< "$(awk '/^cpu / { for (i=2; i<=NF; i++) total+=$i; idle=$5+$6; print total, idle }' /proc/stat)"

# Read load averages (still needed)
read -r l1 l2 l3 _ < /proc/loadavg

if [ -f "$state_file" ]; then
    read -r t_prev i_prev < "$state_file"
    dt=$((t_now - t_prev))
    di=$((i_now - i_prev))
    if [ "$dt" -gt 0 ]; then
        usage=$(awk -v dt="$dt" -v di="$di" 'BEGIN { printf "%.1f", 100 * (dt - di) / dt }')
    else
        usage="0.0"
    fi
else
    usage="0.0"
fi

# Store current totals for next run
echo "$t_now $i_now" > "$state_file"

printf "%s|%s|%s|%s\n" "$usage" "$l1" "$l2" "$l3"
