{
  config,
  pkgs,
  ...
}: {
  imports = [
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

  nix.settings.experimental-features = ["nix-command" "flakes"];

  services.qemuGuest.enable = true;

  boot.kernelParams = ["video=1920x1080@60"];
  boot.kernelModules = ["virtio_gpu"];

  environment.pathsToLink = ["/share/applications" "/share/xdg-desktop-portal"];

  system.stateVersion = "25.11";
}
