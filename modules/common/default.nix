{...}:

{
  imports = [
    ./docker.nix
    ./users.nix
  ];

  nixpkgs.config.allowUnfree = true;

  programs.nix-ld.enable = true;
}
