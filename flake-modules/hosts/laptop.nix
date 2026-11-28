{config, inputs, mkNixosSystem, ...}: {
  flake.nixosConfigurations.laptop = mkNixosSystem {
    modules = [
      config.flake.modules.nixos.common
      config.flake.modules.nixos.common-syncthing
      config.flake.modules.nixos.desktop
      inputs.nixos-hardware.nixosModules.dell-precision-5530
      ../../hosts/laptop
    ];
    home = config.flake.modules.homeManager.home-desktop;
  };
}
