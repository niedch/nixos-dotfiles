{ pkgs, ... }: {
  home.packages = with pkgs; [
    herdr
  ];

  xdg.configFile."herdr/config.toml".source = ./config.toml;
}
