{...}: {
  flake.modules.nixos.common-lunix = {pkgs, ...}: {
    boot.kernelPackages = pkgs.linuxPackages_latest;
  };
}
