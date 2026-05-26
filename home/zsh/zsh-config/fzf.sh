[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
[ -f $HOME/.local/share/forgit/forgit.plugin.zsh ] && source $HOME/.local/share/forgit/forgit.plugin.zsh

PATH="$PATH:$HOME/.local/share/forgit/bin"
export FZF_DEFAULT_OPTS='--height 80% --layout reverse --border top'

#region fzf autocomplete kubectl
_fzf_complete_kubectl() {
  _fzf_complete --multi --reverse --header-lines=1 -- "$@" < <(
    eval "arr=(${@})"

    if [ ${arr: -1} = "logs" ] || [ ${arr: -1} = "exec" ]; then
      kubectl get pods
    elif [ ${arr: -1} = "-f" ]; then
      find *
    elif [ ${arr: -1} = "get" ] || [ ${arr: -1} = "describe" ]; then
      kubectl api-resources
    else
      kubectl get ${arr: -1}
      if [ $? != 0 ]; then
        echo "Nothing found!"
      fi
    fi
  )
}

_fzf_complete_kubectl_post() {
  awk '{print $1}'
}

[ -n "$BASH" ] && complete -F _fzf_complete_kubectl -o default -o bashdefault kubectl
#endregion

#region fzf autocomplete docker
see_details() {
  ID = echo -e $1 | awk '{print $1}'
  return docker ps --format 'ID: {{.ID}}\nName: {{.Names}}\nImage: {{.Image}}\nPorts: {{.Ports}}' | grep $ID
}

_fzf_complete_docker() {
  _fzf_complete --multi --reverse --header-lines=1 -- "$@" < <(
    docker ps -a --format 'table {{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Ports}}'
  )
}

_fzf_complete_docker_post() {
  awk '{print $1}'
}

[ -n "$BASH" ] && complete -F _fzf_complete_docker -o default -o bashdefault docker
#. ~/docker-fzf.sh
#endregion
