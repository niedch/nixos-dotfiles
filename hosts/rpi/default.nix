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

  users.users.nic = {
    isNormalUser = true;
    extraGroups = ["wheel"];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPrMVVkKpJ532z3GkVnxeQE6SDZXoih0wYCmnaYnaR+f christoph.niederer99@gmail.com"
    ];
  };

  nix.settings.require-sigs = false;
  system.stateVersion = "26.05";
}
