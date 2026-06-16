{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./hyprland.nix
    ./displaymanager.nix
    ./fonts.nix
    ./steam.nix
  ];

  # dconf D-Bus service is required for gsettings changes to propagate through
  # xdg-desktop-portal to apps like Brave/Chromium (prefers-color-scheme).
  programs.dconf.enable = true;

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
    allowedTCPPorts = [53317];
    allowedUDPPorts = [53317];
  };

  # Brave only reads policies from /etc/brave/policies/managed/ (not ~/.config/brave/)
  # Symlink it to the user config so the theme-switcher (omarchy-themes) can update
  # colors dynamically without needing root.
  systemd.tmpfiles.rules = [
    "d /etc/brave 0755 root root -"
    "L+ /etc/brave/policies/managed - - - - /home/nic/.config/brave/policies/managed"
  ];
}
