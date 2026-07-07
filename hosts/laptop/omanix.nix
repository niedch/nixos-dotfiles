{
  inputs,
  pkgs,
  lib,
  ...
}: {
  imports = [
    inputs.omanix.nixosModules.default
    # ../../modules/desktop/displaymanager.nix
  ];

  omanix = {
    enable = true;
    login.enable = true; # keep Ly display manager
    theme = "tokyo-night";
    wallpaperIndex = 0;
    steam.enable = true;
    docker.enable = false; # enabled in modules/common/docker.nix
    libreoffice.enable = false;
    devenv.enable = false;
    sunshine.enable = false;
  };

  environment.pathsToLink = ["/share/applications" "/share/xdg-desktop-portal"];

  programs.dconf.enable = true;

  services.fwupd = {
    enable = true;
    extraRemotes = [];
  };

  systemd.services.fwupd-refresh.serviceConfig.ExecStart =
    lib.mkForce "${pkgs.fwupd}/bin/fwupdmgr refresh --ignore-embargo";

  systemd.timers.fwupd-refresh.enable = false;

  networking.firewall = {
    allowedTCPPorts = [53317];
    allowedUDPPorts = [53317];
  };
}
