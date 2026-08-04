{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  imports = [
    inputs.microvm.nixosModules.microvm
  ];

  microvm = {
    hypervisor = "qemu";
    vcpu = 4;
    mem = 4096;

    interfaces = [
      {
        type = "user";
        id = "vm0";
        mac = "02:00:00:00:00:01";
      }
    ];

    kernelParams = ["video=1920x1080@60"];

    graphics.enable = true;

    writableStoreOverlay = "/nix/.rw-store";

    volumes = [
      {
        mountPoint = "/var";
        image = "var.img";
        size = 64;
      }
      {
        mountPoint = config.microvm.writableStoreOverlay;
        image = "nix-store-overlay.img";
        size = 8192;
      }
    ];
  };

  # Disable SOPS - microvm has no stable host key at build time
  sops.enable = false;

  networking.hostName = "microvm";
  networking.networkmanager.enable = true;

  users.users.nic.initialPassword = "nic";

  time.timeZone = "Europe/Vienna";

  services.qemuGuest.enable = true;

  services.seatd.enable = true;

  users.users.nic.extraGroups = ["input"];

  system.stateVersion = "25.11";
}
