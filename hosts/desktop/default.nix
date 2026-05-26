{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";
  boot.loader.grub.useOSProber = true;

  networking.hostName = "nixos";

  # Enable networking
  networking.networkmanager.enable = true;
  time.timeZone = "Europe/Vienna";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.nic = {
    description = "Christoph";
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" ];
    # shell = pkgs.zsh;
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "25.11";
}
