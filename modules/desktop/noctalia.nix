{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.nixosDotfiles.noctalia;
in {
  options.nixosDotfiles.noctalia.enable =
    lib.mkEnableOption "Noctalia shell on Niri as a trial login session";

  config = lib.mkIf cfg.enable {
    programs.niri.enable = true;

    nix.settings = {
      extra-substituters = ["https://cache.thalheim.io"];
      extra-trusted-public-keys = [
        "cache.thalheim.io-1:R7msbosLEZKrxk/lKxf9BTjOOH7Ax3H0Qj0/6wiHOgc="
      ];
    };
  };
}