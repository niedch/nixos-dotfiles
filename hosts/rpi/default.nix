{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [./hardware-configuration.nix];

  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  networking.hostName = "rpi";
  networking.networkmanager.enable = true;
  networking.extraHosts = ''
    127.0.0.1 rpi
    ::1 rpi
  '';

  time.timeZone = "Europe/Vienna";

  users.groups.usb-toggler = {};

  users.users.nic = {
    isNormalUser = true;
    extraGroups = ["wheel" "usb-toggler"];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPrMVVkKpJ532z3GkVnxeQE6SDZXoih0wYCmnaYnaR+f christoph.niederer99@gmail.com"
    ];
  };

  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ACTION=="add", RUN+="${pkgs.coreutils}/bin/chmod 0660 /sys/bus/usb/drivers/usb/bind /sys/bus/usb/drivers/usb/unbind"
    SUBSYSTEM=="usb", ACTION=="add", RUN+="${pkgs.coreutils}/bin/chgrp usb-toggler /sys/bus/usb/drivers/usb/bind /sys/bus/usb/drivers/usb/unbind"
  '';

  nix.settings.require-sigs = false;

  system.stateVersion = "26.05";
}
