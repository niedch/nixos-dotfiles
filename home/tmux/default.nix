{pkgs, ...}: let
  tmux = import ./package.nix {inherit pkgs;};
in {
  home.packages = with pkgs; [
    tmux
    yq
    elinks
  ];
}
