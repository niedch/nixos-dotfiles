{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./dux.nix
    ./hyprland.nix
    ./fonts.nix
    ./steam.nix
    ./virt-manager.nix
    ./rclone.nix
    ./samba-mount.nix
    ./lazy.nix
    ./proton.nix
    ./localsend.nix
  ];

  # dconf D-Bus service is required for gsettings changes to propagate through
  # xdg-desktop-portal to apps like Chromium (prefers-color-scheme).
  programs.dconf.enable = true;

  # udisks2 provides the daemon that udiskie talks to for mounting removable
  # media (USB drives, SD cards) to /run/media/$USER/<label>.
  services.udisks2.enable = true;

  # GVfs provides virtual filesystem support, trash functionality (trash://),
  # and volume management for desktop file managers like Nautilus.
  services.gvfs.enable = true;

  # UPower daemon + D-Bus service for monitoring power and battery level.
  services.upower.enable = true;

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

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = false;
  };
}
