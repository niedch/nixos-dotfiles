[ -f $HOME/.local/share/forgit/forgit.plugin.zsh ] && source $HOME/.local/share/forgit/forgit.plugin.zsh
PATH="$PATH:$HOME/.local/share/forgit/bin"

#region fzf Autcomplete git
_fzf_complete_git() {
  _fzf_complete --multi --reverse -- "$@" < <(
    git branch -r
  )
}

_fzf_complete_git_post() {
  sed -e 's/\origin\///g'
}

[ -n "$BASH" ] && complete -F _fzf_complete_git -o default -o bashdefault git
#endregion

alias ga='git ga'
