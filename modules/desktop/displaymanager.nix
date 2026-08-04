{pkgs, ...}: {
  services.displayManager.ly = {
    enable = true;
  };

  services.displayManager.autoLogin = {
    enable = true;
    user = "nic";
  };
}
