{config, ...}: {
  flake.modules.homeManager.home-media-docs = {...}: {
    imports = with config.flake.modules.homeManager; [
      home-media-docs-pdf
      home-media-docs-obsidian
    ];
  };
}
