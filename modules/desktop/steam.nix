{
  config,
  pkgs,
  lib,
  ...
}: {
  programs.steam = {
    enable = true;
    extraCompatPackages = [
      pkgs.proton-ge-bin
    ];
  };

  environment.systemPackages = lib.mkIf config.hardware.nvidia.prime.offload.enable [
    (let
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
      patchDesktop pkgs.steam "steam" "^Exec=" "Exec=nvidia-offload ")
  ];
}
