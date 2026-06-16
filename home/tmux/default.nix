{pkgs, ...}: {
  home.packages = with pkgs; [
    tmux
    yq
    elinks
  ];

  xdg.configFile."tmux/tmux.conf".source = ./tmux.conf;

  xdg.configFile."tmux/tmux-sessionizer.sh" = {
    source = ./tmux-sessionizer.sh;
    executable = true;
  };

  xdg.configFile."tmux/tmux-popup.sh" = {
    source = ./tmux-popup.sh;
    executable = true;
  };

  xdg.configFile."tmux/tmux-opener.sh" = {
    source = ./tmux-opener.sh;
    executable = true;
  };
}
