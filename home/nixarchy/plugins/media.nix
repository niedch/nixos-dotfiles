{
  pkgs,
  lib,
  ...
}: {
  programs.nixarchy.plugins.mpris.src = pkgs.fetchgit {
    name = "omarchy-mpris";
    url = "https://github.com/crmne/omarchy-mpris.git";
    rev = "411abaeec96cd9e09d53e4a87ed82417944344e7";
    hash = "sha256-vW80C5ZeCRnUEvZdjW1E0Ak0Fu6qFauVEoM6m87Vw7k=";
  };
}
