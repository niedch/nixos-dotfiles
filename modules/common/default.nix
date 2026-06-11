{...}:

{
  imports = [
    ./docker.nix
    ./users.nix
    ./ssh.nix
  ];

  nixpkgs.config.allowUnfree = true;

  programs.nix-ld.enable = true;
}
