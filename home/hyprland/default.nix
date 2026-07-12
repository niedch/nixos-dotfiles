{pkgs, ...}: {
  imports = [
    ./services.nix
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    package = pkgs.hyprland;
    systemd.enable = true;
  };

  xdg.configFile."hypr/hyprland.lua".source = ./hyprland.lua;
  xdg.configFile."hypr/conf".source = ./conf;
  xdg.configFile."hypr/hypridle.conf".source = ./hypridle.conf;
  xdg.configFile."hypr/hyprlock.conf".source = ./hyprlock.conf;
  xdg.configFile."hypr/hyprsunset.conf".source = ./hyprsunset.conf;
  xdg.configFile."hypr/toggle-sunset.sh" = {
    source = ./toggle-sunset.sh;
    executable = true;
  };

  xdg.portal = {
    extraPortals = with pkgs; [xdg-desktop-portal-gtk];
    config.hyprland = {
      default = ["hyprland" "gtk"];
    };
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      cursor-size = 24;
      text-scaling-factor = 1.0;
    };
  };

  home.packages = with pkgs; [
    mako
    wl-clipboard
    bibata-cursors
    hypridle
    hyprlock
    hyprpicker
    hyprsunset
    playerctl
    brightnessctl
    nautilus
    polkit_gnome
    libnotify
    jq
    swaybg
    wayfreeze
    wl-screenrec
  ];
}
