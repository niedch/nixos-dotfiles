{...}: {
  flake.modules.homeManager.home-ghostty = {pkgs, ...}: {
    home.packages = with pkgs; [
      ghostty
    ];

    xdg.configFile."ghostty/config" = {
      source = ./ghostty.config;
    };

    xdg.configFile."ghostty/theme" = {
      source = ./theme.config;
    };

    xdg.configFile."ghostty/tmux-start.sh" = {
      source = ./tmux-start.sh;
      executable = true;
    };
  };
}
