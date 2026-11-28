{config, inputs, mkNixosSystem, ...}: {
  flake.nixosConfigurations.dobby = mkNixosSystem {
    modules = [
      config.flake.modules.nixos.common
      config.flake.modules.nixos.common-syncthing
      inputs.nixos-hardware.nixosModules.common-pc-ssd
      config.flake.modules.nixos.server-openssh
      config.flake.modules.nixos.server-immich
      config.flake.modules.nixos.server-nix-cache
      config.flake.modules.nixos.server-samba
      config.flake.modules.nixos.server-github-runner
      config.flake.modules.nixos.server-gameserver
      inputs.speedtest-tracker.nixosModules.default
      inputs.nixflix.nixosModules.default
      config.flake.modules.nixos.server-glance
      config.flake.modules.nixos.server-nixflix
      config.flake.modules.nixos.server-gittea
      config.flake.modules.nixos.server-deploy-nodes
      config.flake.modules.nixos.server-cockpit
      ../../hosts/dobby
    ];
    home = config.flake.modules.homeManager.home-server;
  };
}
