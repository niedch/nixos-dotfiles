{
  inputs,
  pkgs,
  ...
}: let
  mux-session = import ./package.nix {
    inherit pkgs;
    mux-session = inputs.mux-session.packages.${pkgs.stdenv.hostPlatform.system}.default;
  };
in {
  home.packages = [
    mux-session
  ];
}
