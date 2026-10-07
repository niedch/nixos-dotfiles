# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "dobby";

  # Expose the Syncthing web GUI on the LAN (reachable at http://dobby:8384).
  services.syncthing.guiAddress = "0.0.0.0:8384";
  networking.firewall.allowedTCPPorts = [8384];

  networking.networkmanager.enable = true;

  programs.zsh.enable = true;

  time.timeZone = "Europe/Vienna";

  environment.systemPackages = with pkgs; [
    exfatprogs
  ];

  nix.settings.require-sigs = false;
  system.stateVersion = "25.11"; # Did you read the comment?
}
