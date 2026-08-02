#!/usr/bin/env bash
set -u

cpu_sample() {
    awk '
        /^cpu / {
            for (i = 2; i <= NF; i++) total += $i
            idle = $5 + $6
            print total, idle
        }
    ' /proc/stat
}

read -r t1 i1 <<< "$(cpu_sample)"
sleep 0.2
read -r t2 i2 <<< "$(cpu_sample)"

usage=$(awk -v t1="$t1" -v i1="$i1" -v t2="$t2" -v i2="$i2" '
    BEGIN {
        dt = t2 - t1
        di = i2 - i1
        printf "%.1f", (dt > 0) ? 100 * (dt - di) / dt : 0
    }
')

read -r l1 l2 l3 _ < /proc/loadavg

printf "%s|%s|%s|%s\n" "$usage" "$l1" "$l2" "$l3"
