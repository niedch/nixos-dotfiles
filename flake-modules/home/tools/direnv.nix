{...}: {
  flake.modules.homeManager.home-tools-direnv = {...}: {
    programs.direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };
  };
}
