{ pkgs, ... }:
{
  programs.hyprland = {
    enable = true;
  };

  services.displayManager.defaultSession = "hyprland";

  # Hyprland is launched directly by greetd/dms-greeter, so nothing activates the
  # passive graphical-session.target. This wrapper pulls it in as a dependency
  # (graphical-session.target is RefuseManualStart=yes). autostart.lua starts it
  # after exporting the Wayland environment.
  systemd.user.targets.hyprland-session = {
    Unit = {
      Description = "Hyprland compositor session";
      Documentation = [ "man:systemd.special(7)" ];
      BindsTo = [ "graphical-session.target" ];
      Wants = [ "graphical-session-pre.target" ];
      After = [ "graphical-session-pre.target" ];
    };
  };

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
