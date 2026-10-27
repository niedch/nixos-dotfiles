{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  imports = [
    inputs.nix-lazy-apps.nixosModules.default
  ];

  programs.steam = {
    enable = true;
    extraCompatPackages = [
      pkgs.proton-ge-bin
    ];
  };

  environment.systemPackages = lib.mkIf config.hardware.nvidia.prime.offload.enable [
    (
      let
        patchDesktop = pkg: appName: from: to:
          lib.hiPrio (
            pkgs.runCommand "patched-desktop-entry-for-${appName}" {} ''
              ${pkgs.coreutils}/bin/mkdir -p $out/share/applications
              ${pkgs.gnused}/bin/sed 's#${from}#${to}#g' \
                < ${pkg}/share/applications/${appName}.desktop \
                > $out/share/applications/${appName}.desktop
            ''
          );
      in
        patchDesktop pkgs.steam "steam" "^Exec=" "Exec=nvidia-offload "
    )
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
