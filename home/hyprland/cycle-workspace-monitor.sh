#!/usr/bin/env bash

monitors=($(hyprctl monitors -j | jq -r '.[].name'))
current=$(hyprctl activeworkspace -j | jq -r '.monitor')

[[ ${#monitors[@]} -le 1 ]] && exit 0

for i in "${!monitors[@]}"; do
	if [[ "${monitors[$i]}" == "$current" ]]; then
		next=$(( (i + 1) % ${#monitors[@]} ))
		hyprctl dispatch "hl.dsp.workspace.move({ monitor = \"${monitors[$next]}\" })"
		exit 0
	fi
done
