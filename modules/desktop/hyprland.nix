{ pkgs, ... }:
{
  programs.hyprland = {
    enable = true;
  };

  services.displayManager.defaultSession = "hyprland";

  security.polkit.enable = true;

  environment.systemPackages = with pkgs; [
    wl-clipboard
    brightnessctl
    playerctl
  ];

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    XDG_SESSION_TYPE = "wayland";
  };

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-hyprland
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-gnome
    ];
    config = {
      common = {
        default = [ "gtk" ];
      };
      hyprland = {
        default = [
          "hyprland"
          "gtk"
        ];
        "org.freedesktop.impl.portal.FileChooser" = [ "gnome" ];
      };
    };
  };
}
