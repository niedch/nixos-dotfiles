{config, lib, ...}: {
  flake.modules.nixos.common = {pkgs, ...}: {
    imports = with config.flake.modules.nixos; [
      common-binfmt
      common-cache-config
      common-nix-gc
      common-docker
      common-users
      common-ssh
      common-sops
      common-message-board-client
      common-unfree
      common-glances
      common-lunix
    ];

    sops.enable = lib.mkDefault true;

    nix.settings = {
      experimental-features = ["nix-command" "flakes"];
      trusted-users = ["root" "nic"];
    };

    programs.nix-ld.enable = true;

    environment.systemPackages = [pkgs.acl];
  };
}
