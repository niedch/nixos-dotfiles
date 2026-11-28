{...}: {
  flake.modules.homeManager.home-media-music-spotify = {pkgs, ...}: {
    home.packages = with pkgs; [
      spotify
      spicetify-cli
    ];
  };
}
