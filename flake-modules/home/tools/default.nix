{config, ...}: {
  flake.modules.homeManager.home-tools = {...}: {
    imports = with config.flake.modules.homeManager; [
      home-tools-mux-session
      home-tools-comd
      home-tools-btop
      home-tools-direnv
      home-tools-docker
      home-tools-development
    ];
  };
}
