{config, ...}: {
  flake.modules.homeManager.home-media = {...}: {
    imports = with config.flake.modules.homeManager; [
      home-media-video
      home-media-image
      home-media-docs
      home-media-music
      home-media-nautilus
    ];
  };
}
