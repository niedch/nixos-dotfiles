{...}: {
  flake.modules.homeManager.home-tools-docker = {pkgs, ...}: {
    home.packages = with pkgs; [
      docker-compose
      lazydocker
    ];
  };
}
