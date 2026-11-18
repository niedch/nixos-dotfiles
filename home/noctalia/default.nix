{
  config,
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.noctalia.homeModules.default
    ./wallpapers.nix
    ./plugins
    ./calendar.nix
  ];

  home.pointerCursor = {
    enable = true;
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 16;
  };

  programs.noctalia = {
    enable = true;
  };

  xdg.configFile."noctalia/config.toml" = {
    source = ./config.toml;
  };
}
