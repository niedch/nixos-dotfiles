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

  nix.settings.require-sigs = false;
  system.stateVersion = "26.05";
}
