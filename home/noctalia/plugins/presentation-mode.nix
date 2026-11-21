{
  pkgs,
  ...
}: {
  # Noctalia scans ~/.local/share/noctalia/plugins/<plugin>/ for local plugins
  xdg.dataFile."noctalia/plugins/presentation-mode".source = ./presentation-mode;

  home.packages = [
    pkgs.procps
    pkgs.glib
  ];
}
