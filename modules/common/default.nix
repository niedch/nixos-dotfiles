{...}: {
  imports = [
    ./binfmt.nix
    ./cache-config.nix
    ./docker.nix
    ./users.nix
    ./ssh.nix
    ./sops.nix
  ];

  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
    trusted-users = ["root" "nic"];
  };
  nixpkgs.config.allowUnfree = true;

  programs.nix-ld.enable = true;
}
