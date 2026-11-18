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
}
