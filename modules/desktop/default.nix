{ pkgs, lib, ... }:
{
  imports = [
    ./hyprland.nix
    ./displaymanager.nix
    ./fonts.nix
  ];

  services.fwupd = {
    enable = true;
    extraRemotes = [];
  };

  # fwupd-refresh.service periodically checks for firmware updates from LVFS.
  # It runs as fwupd-refresh user which can't read secret.key needed for
  # the embargo remote (pre-release firmware under NDA, requires vendor auth).
  # Skip embargo since we don't use it.
  systemd.services.fwupd-refresh.serviceConfig.ExecStart =
    lib.mkForce "${pkgs.fwupd}/bin/fwupdmgr refresh --ignore-embargo";

  systemd.timers.fwupd-refresh.enable = false;

  # localsend uses this port for LAN discovery and file transfer
  networking.firewall = {
    allowedTCPPorts = [ 53317 ];
    allowedUDPPorts = [ 53317 ];
  };
}
