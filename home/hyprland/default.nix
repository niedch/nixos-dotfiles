{
  pkgs,
  inputs,
  lib,
  ...
}: {
  imports = [./capture.nix];

  wayland.windowManager.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    systemd.enable = false;
  };

  systemd.user.services.polkit-gnome = {
    Unit = {
      Description = "PolicyKit Authentication Agent";
    };
    Install = {
      WantedBy = ["hyprland-session.target"];
    };
    Service = {
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };

  xdg.configFile."hypr/hyprland.lua".source = ./hyprland.lua;
  xdg.configFile."hypr/conf".source = ./conf;
  xdg.configFile."hypr/hypridle.conf".source = ./hypridle.conf;
  xdg.configFile."hypr/hyprlock.conf".source = ./hyprlock.conf;
  xdg.configFile."hypr/hyprsunset.conf".source = ./hyprsunset.conf;

  xdg.portal = {
    extraPortals = with pkgs; [xdg-desktop-portal-gtk];
    config.hyprland = {
      default = ["hyprland" "gtk"];
    };
  };

  home.packages = with pkgs; [
    mako
    wl-clipboard
    bibata-cursors
    hypridle
    hyprlock
    hyprpicker
    playerctl
    brightnessctl
    nautilus
    polkit_gnome
    libnotify
    jq
    swaybg
  ];
}
