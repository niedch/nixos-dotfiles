{...}: {
  flake.modules.homeManager.home-tools-mux-session = {inputs, pkgs, ...}: let
    mux-session = import ./mux-session.pkg.nix {
      inherit pkgs;
      mux-session = inputs.mux-session.packages.${pkgs.stdenv.hostPlatform.system}.default;
    };
  in {
    home.packages = [
      mux-session
    ];
  };
}
