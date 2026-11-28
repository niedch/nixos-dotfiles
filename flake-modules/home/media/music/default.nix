{config, ...}: {
  flake.modules.homeManager.home-media-music = {...}: {
    imports = with config.flake.modules.homeManager; [
      home-media-music-spotify
    ];
  };
}
