{
  inputs,
  pkgs,
  ...
}: {
  home.packages = [
    inputs.mux-session.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  xdg.configFile."mux-session/config.toml".source = ./config.toml;
}
