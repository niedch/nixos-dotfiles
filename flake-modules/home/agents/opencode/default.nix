{...}: {
  flake.modules.homeManager.home-agents-opencode = {pkgs, ...}: let
    opencode = import ./opencode.pkg.nix {inherit pkgs;};
  in {
    home.packages = with pkgs; [
      opencode
      jq
    ];

    xdg.configFile."opencode" = {
      source = ./config;
      recursive = true;
    };
  };
}
