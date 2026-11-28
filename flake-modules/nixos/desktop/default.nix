{config, lib, ...}: {
  flake.modules.nixos.desktop = {pkgs, ...}: {
    imports = with config.flake.modules.nixos; [
      desktop-dux
      desktop-hyprland
      desktop-fonts
      desktop-steam
      desktop-virt-manager
      desktop-rclone
      desktop-samba-mount
      desktop-lazy
      desktop-proton
      desktop-localsend
    ];

    # dconf D-Bus service is required for gsettings changes to propagate through
    # xdg-desktop-portal to apps like Chromium (prefers-color-scheme).
    programs.dconf.enable = true;

    # udisks2 provides the daemon that udiskie talks to for mounting removable media.
    services.udisks2.enable = true;

    # GVfs provides virtual filesystem support, trash, and volume management.
    services.gvfs.enable = true;

    # UPower daemon for monitoring power and battery level.
    services.upower.enable = true;

    services.fwupd = {
      enable = true;
      extraRemotes = [];
    };

    # fwupd-refresh.service periodically checks for firmware updates from LVFS.
    # Skip the embargo remote (pre-release firmware under NDA).
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
  };
}
