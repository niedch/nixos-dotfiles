{pkgs, ...}: {
  xdg.configFile."mux-session/config.toml".source = ./config.toml;
}
