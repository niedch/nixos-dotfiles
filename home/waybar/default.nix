{ pkgs, ... }:

{
  programs.waybar = {
    enable = true;
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

  xdg.configFile."waybar/indicators/screen-recording.sh" = {
    source = ./indicators/screen-recording.sh;
    executable = true;
  };

  home.packages = with pkgs; [ cava ];
}
