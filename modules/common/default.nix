{
  lib,
  ...
}: {
  imports = [
    ./binfmt.nix
    ./cache-config.nix
    ./nix-gc.nix
    ./docker.nix
    ./users.nix
    ./ssh.nix
    ./sops.nix
    ./message-board-client.nix
    ./unfree.nix
  ];

  config = {
    sops.enable = lib.mkDefault true;

    nix.settings = {
      experimental-features = ["nix-command" "flakes"];
      trusted-users = ["root" "nic"];
    };

    programs.nix-ld.enable = true;
  };
}
