{
  pkgs,
  lib,
  ...
}: let
  herdr-opencode = pkgs.writeShellScriptBin "herdr-opencode" ''
    export PATH="${lib.makeBinPath [pkgs.herdr pkgs.git]}:''${PATH}"
    exec ${pkgs.python3}/bin/python3 ${./herdr-opencode.py} "$@"
  '';
in {
  home.packages = with pkgs; [
    herdr
    herdr-opencode
  ];

  xdg.configFile."herdr/config.toml".source = ./config.toml;
}
