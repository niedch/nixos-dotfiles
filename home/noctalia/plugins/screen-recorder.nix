{
  pkgs,
  ...
}: let
  src = pkgs.fetchFromGitHub {
    owner = "noctalia-dev";
    repo = "official-plugins";
    rev = "8b99df3ca7e35822b938bf92fb32e8cc2f90027e";
    hash = "sha256-iUIwljJGup34okKOYOxFMxF2woK9mv0wg7o5DuuHkB4=";
  };
in {
  # Noctalia scans ~/.local/share/noctalia/plugins/<plugin>/ for local plugins
  xdg.dataFile."noctalia/plugins/screen-recorder".source = "${src}/screen_recorder";


  home.packages = [
    pkgs.gpu-screen-recorder
  ];
}
