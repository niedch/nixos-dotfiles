#!/usr/bin/env bash

p1=$(awk '/^cpu / {t=$2+$3+$4+$5+$6+$7+$8+$9+$10+$11; i=$5+$6; print t, i}' /proc/stat)
sleep 0.2
p2=$(awk '/^cpu / {t=$2+$3+$4+$5+$6+$7+$8+$9+$10+$11; i=$5+$6; print t, i}' /proc/stat)

read -r t1 i1 <<<"$p1"
read -r t2 i2 <<<"$p2"

usage=$(awk -v t1="$t1" -v i1="$i1" -v t2="$t2" -v i2="$i2" 'BEGIN { dt=t2-t1; di=i2-i1; if (dt>0) printf "%.1f", 100*(dt-di)/dt; else printf "0" }')

read -r l1 l2 l3 _ < /proc/loadavg

echo "$usage|$l1|$l2|$l3"
