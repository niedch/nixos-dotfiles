{ pkgs, lib, ... }: {
  programs.nixarchy.plugins.mpris.src = pkgs.fetchgit {
    name = "omarchy-mpris";
    url = "https://github.com/crmne/omarchy-mpris.git";
    rev = "ef8e3e737830ad409fd954d4273f2a3caee20a1b";
    hash = "sha256-sFT1dpEl1/BUHuH8Ry/bUpyzy0j3ljpJ+JEwplW5Bms=";
  };
}
