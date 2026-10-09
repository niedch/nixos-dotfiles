{pkgs, ...}: {
  xdg.configFile."ghostty/config" = {
    source = ./ghostty.config;
  };

  xdg.configFile."ghostty/tmux-start.sh" = {
    source = ./tmux-start.sh;
    executable = true;
  };
}
