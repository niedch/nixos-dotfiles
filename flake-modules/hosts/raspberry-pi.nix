{config, mkNixosSystem, ...}: {
  flake.nixosConfigurations.raspberry-pi = mkNixosSystem {
    modules = [
      # inputs.nixos-hardware.nixosModules.raspberry-pi-3
      config.flake.modules.nixos.common-sops
      config.flake.modules.nixos.common-ssh
      config.flake.modules.nixos.common-users
      config.flake.modules.nixos.common-cache-config
      config.flake.modules.nixos.common-nix-gc
      config.flake.modules.nixos.common-unfree
      config.flake.modules.nixos.common-message-board-client
      config.flake.modules.nixos.server-openssh
      config.flake.modules.nixos.server-homebridge
      ../../hosts/rpi
    ];
    home = config.flake.modules.homeManager.home-server;
  };
}
