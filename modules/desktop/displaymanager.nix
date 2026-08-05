{pkgs, ...}: {
  services.displayManager.ly = {
    enable = true;
  };

  services.displayManager.autoLogin = {
    enable = true;
    user = "nic";
  };

  services.displayManager.ly.settings.auto_login_session = "Hyprland";
}
