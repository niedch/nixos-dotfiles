{ inputs, pkgs, ... }: {
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
        package = pkgs.intellij-idea;
        icon = pkgs.fetchurl {
          url = "https://raw.githubusercontent.com/JetBrains/logos/master/web/intellij-idea/intellij-idea.svg";
          name = "intellij-idea.svg";
          sha256 = "sha256-XuJzogTDxbOjOjkmnGzv2HiQva+mR5dYDa6vjqMjRsc=";
        };
      }
    ];
  };
}
