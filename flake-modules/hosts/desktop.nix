{config, mkNixosSystem, ...}: {
  flake.nixosConfigurations.desktop = mkNixosSystem {
    modules = [
      config.flake.modules.nixos.common
      config.flake.modules.nixos.common-syncthing
      config.flake.modules.nixos.desktop
      ../../hosts/desktop
    ];
    home = config.flake.modules.homeManager.home-desktop;
  };
}
