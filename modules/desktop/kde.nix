{
  config,
  pkgs,
  lib,
  ...
}: {
  # Enable the X11 windowing system (needed for Xwayland and display managers)
  services.xserver.enable = true;

  # Enable the SDDM display manager with Wayland support
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = lib.mkDefault true;
  };

  # Enable the KDE Plasma 6 Desktop Environment
  services.desktopManager.plasma6.enable = true;

  # Configure automatic login for the user 'nic'
  services.displayManager.autoLogin = {
    enable = true;
    user = "nic";
  };

  # Core KDE utility packages
  environment.systemPackages = with pkgs.kdePackages; [
    kate
    kcalc
    spectacle
    gwenview
    okular
  ];
}
