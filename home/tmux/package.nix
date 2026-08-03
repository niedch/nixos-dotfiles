{pkgs}: let
  tmuxConfig = pkgs.runCommand "tmux-config" {} ''
    mkdir -p $out
    install -m 0644 ${./tmux.conf} $out/tmux.conf
    install -m 0755 ${./tmux-sessionizer.sh} $out/tmux-sessionizer.sh
    install -m 0755 ${./tmux-popup.sh} $out/tmux-popup.sh
    install -m 0755 ${./tmux-opener.sh} $out/tmux-opener.sh
  '';
in
  pkgs.writeShellScriptBin "tmux" ''
    export PATH=${tmuxConfig}:$PATH
    exec ${pkgs.tmux}/bin/tmux -f ${tmuxConfig}/tmux.conf "$@"
  ''
