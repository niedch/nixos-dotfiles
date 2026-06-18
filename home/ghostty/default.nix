{pkgs, ...}: {
  programs.ghostty = {
    enable = true;
    package = pkgs.ghostty;
    settings = {
      "config-file" = "?~/.local/share/themes/current/ghostty.conf";

      "font-family" = "JetBrainsMono Nerd Font Mono";
      "font-style" = "Regular";
      "font-size" = 9;

      "window-theme" = "ghostty";
      "window-padding-x" = 8;
      "window-padding-y" = 4;
      "confirm-close-surface" = false;
      "resize-overlay" = "never";
      "gtk-toolbar-style" = "flat";
      "background-opacity" = 0.9;

      "cursor-style" = "block";
      "cursor-style-blink" = false;
      "shell-integration-features" = "no-cursor,ssh-env";

      "keybind" = [
        "shift+insert=paste_from_clipboard"
        "control+insert=copy_to_clipboard"
        "super+control+shift+alt+arrow_down=resize_split:down,100"
        "super+control+shift+alt+arrow_up=resize_split:up,100"
        "super+control+shift+alt+arrow_left=resize_split:left,100"
        "super+control+shift+alt+arrow_right=resize_split:right,100"
      ];

      "mouse-scroll-multiplier" = 0.95;
      "async-backend" = "epoll";
      "command" = "~/.config/ghostty/tmux-start.sh";
    };
  };

  xdg.configFile."ghostty/tmux-start.sh" = {
    source = ./tmux-start.sh;
    executable = true;
  };
}
