{
  lib,
  config,
  inputs,
  ...
}: {
  imports = [
    inputs.nix-omarchy-quickshell.homeManagerModules.default
  ];

  programs.quickshell-omarchy = {
    enable = true;
    settings = {
      version = 1;
      bar = {
        position = "top";
        transparent = true;
        centerAnchor = "omarchy.clock";
        layout = {
          left = [
            {id = "omarchy.menu";}
            {id = "omarchy.workspaces";}
          ];
          center = [
            {id = "omarchy.clock";}
          ];
          right = [
            {id = "omarchy.tray";}
            {id = "omarchy.audio";}
            {id = "omarchy.network";}
            {id = "omarchy.power";}
          ];
        };
      };
      plugins = [];
    };
  };
}
