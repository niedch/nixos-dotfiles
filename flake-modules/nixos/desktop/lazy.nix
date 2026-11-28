{...}: {
  flake.modules.nixos.desktop-lazy = {inputs, pkgs, ...}: {
    imports = [
      inputs.nix-lazy-apps.nixosModules.default
    ];

    programs.nix-lazy-apps = {
      enable = true;
      follows = inputs.nixpkgs;
      lazyPkgs = [
        {
          package = pkgs.r2modman;
          icon = pkgs.fetchurl {
            url = "https://raw.githubusercontent.com/ebkr/r2modmanPlus/master/src-electron/icons/linux-512x512.png";
            name = "r2modman.png";
            sha256 = "sha256-4QZpWGhz+utEZc6wJgnT6Qfdd3sM9cpmUXB0CwTeRuM=";
          };
        }
        {
          package = pkgs.vscodium;
        }
        {
          package = pkgs.photocraft;
        }
        {
          package = pkgs.wordcraft;
        }
        {
          package = pkgs.gridcraft;
        }
        {
          package = pkgs.pdfcraft;
        }
      ];
    };
  };
}
