{pkgs, ...}: let
  opencode = import ./package.nix {inherit pkgs;};
in {
  home.packages = with pkgs; [
    opencode
  ];
}
