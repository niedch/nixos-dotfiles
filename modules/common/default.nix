{...}: {
  imports = [
    ./binfmt.nix
    ./docker.nix
    ./users.nix
    ./ssh.nix
    ./sops.nix
  ];

  nix.settings.trusted-users = ["root" "nic"];
  nixpkgs.config.allowUnfree = true;

  programs.nix-ld.enable = true;
}
