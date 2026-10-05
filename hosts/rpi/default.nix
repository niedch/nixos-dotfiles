{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [./hardware-configuration.nix];

  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  # Pin to the 6.12 LTS kernel. The 6.18.x series has a known ethernet
  # regression on Raspberry Pi (lan78xx/smsc95xx/bcmgenet drivers) that
  # leaves the Pi bootable but with no network. Revisit once upstream
  # confirms the fix is in a newer stable release.
  boot.kernelPackages = pkgs.linuxPackages_6_12;

  networking.hostName = "rpi";
  networking.networkmanager.enable = true;
  networking.extraHosts = ''
    127.0.0.1 rpi
    ::1 rpi
  '';

  time.timeZone = "Europe/Vienna";

  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
    require-sigs = false;
  };
  system.stateVersion = "26.05";
}
