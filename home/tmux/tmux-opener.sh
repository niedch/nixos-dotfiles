#!/bin/bash

if [[ $# -eq 1 ]]; then
  selected=$1
else
  fzfdefault="${FZF_DEFAULT_OPTS}"
  export FZF_DEFAULT_OPTS=''
  selected=$(yq '.[] | keys[] | @sh' .opener.yml | fzf --preview='elinks $(yq -r ".{n} | to_entries[].value" .opener.yml)')
  export FZF_DEFAULT_OPTS=$fzfdefault

  url=$(yq -r ".[] | .$(echo ${selected}) | select(.)" .opener.yml)
fi

if [[ -z $selected ]]; then
    exit 0
fi

xdg-open $url
