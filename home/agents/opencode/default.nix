{pkgs, ...}: let
  opencode = import ./package.nix {inherit pkgs;};
in {
  home.packages = with pkgs; [
    opencode
    jq
  ];

  xdg.configFile."opencode" = {
    source = ./config;
    recursive = true;
  };
}
