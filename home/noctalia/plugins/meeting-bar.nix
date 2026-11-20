{
  pkgs,
  ...
}: let
  src = pkgs.fetchFromGitHub {
    owner = "noctalia-dev";
    repo = "community-plugins";
    rev = "bccbc7f0f0c888814e506aa0ce48cbc8d90c91f0";
    hash = "sha256-LhlJ9cMdF/tNo4sRnlgS5UvEYQ4Ajm67m8aWSghXZbA=";
  };
in {
  # Noctalia scans ~/.local/share/noctalia/plugins/<plugin>/ for local plugins
  xdg.dataFile."noctalia/plugins/meeting-bar".source = "${src}/meeting-bar";


  home.packages = [
    pkgs.xdg-utils
  ];
}
