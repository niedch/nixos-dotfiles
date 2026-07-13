{pkgs, ...}: {
  programs.waybar = {
    enable = true;
    systemd = {
      enable = true;
    };
  };

  xdg.configFile."waybar/config.jsonc".source = ./config.jsonc;
  xdg.configFile."waybar/style.css".source = ./style.css;
  xdg.configFile."waybar/cava.sh" = {
    source = ./cava.sh;
    executable = true;
  };

  xdg.configFile."waybar/weather.sh" = {
    source = ./weather.sh;
    executable = true;
  };

  xdg.configFile."waybar/indicators/screen-recording.sh" = {
    source = ./indicators/screen-recording.sh;
    executable = true;
  };

  xdg.configFile."waybar/indicators/idle.sh" = {
    source = ./indicators/idle.sh;
    executable = true;
  };

  xdg.configFile."waybar/indicators/notification-silencing.sh" = {
    source = ./indicators/notification-silencing.sh;
    executable = true;
  };

  xdg.configFile."waybar/bin/omarchy-weather-status" = {
    source = ./bin/omarchy-weather-status;
    executable = true;
  };

  xdg.configFile."waybar/bin/omarchy-toggle-idle" = {
    source = ./bin/omarchy-toggle-idle;
    executable = true;
  };

  xdg.configFile."waybar/bin/omarchy-toggle-notification-silencing" = {
    source = ./bin/omarchy-toggle-notification-silencing;
    executable = true;
  };

  home.packages = with pkgs; [cava jq];
}
