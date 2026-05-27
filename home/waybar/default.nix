{ pkgs, ... }:

{
  programs.waybar = {
    enable = true;
    package = pkgs.waybar.override { withHyprland = true; };
    systemd = {
      enable = true;
      targets = [ "hyprland-session.target" ];
    };
  };

  xdg.configFile."waybar/config.jsonc".source = ./config.jsonc;
  xdg.configFile."waybar/style.css".source = ./style.css;
  xdg.configFile."waybar/cava.sh" = {
    source = ./cava.sh;
    executable = true;
  };

  home.packages = with pkgs; [ cava ];
}
