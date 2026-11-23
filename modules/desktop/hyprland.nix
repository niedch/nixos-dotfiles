{ pkgs, ... }:
{
  programs.hyprland = {
    enable = true;
  };

  # SDDM Display Manager with Wayland support and autologin
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  services.displayManager.autoLogin = {
    enable = true;
    user = "nic";
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
    ];
    config = {
      common = {
        default = [ "gtk" ];
      };
      hyprland = {
        default = [ "hyprland" "gtk" ];
      };
    };
  };
}
