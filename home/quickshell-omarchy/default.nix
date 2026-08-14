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
            {id = "saif.system-stats";}
            {
              id = "b.omastonk";
              symbol = "BTC-USD";
            }
            {id = "omarchy.power";}
          ];
        };
      };
      plugins = [];
    };

    plugins = {
      "saif.system-stats" = {
        git = "https://github.com/SaifOmar/SystemStats";
        rev = "8ea500546d58739c36520899d51ae30276859cd0";
      };
      "b.omastonk" = {
        git = "https://github.com/brianblakely/omastonk";
        rev = "76a29b16dfc17251953b31df2c0a7cd2ab381e6c";
      };
    };
  };
}
