{config, ...}: {
  flake.modules.homeManager.home-agents = {...}: {
    imports = with config.flake.modules.homeManager; [
      home-agents-herdr
      home-agents-opencode
    ];
  };
}
