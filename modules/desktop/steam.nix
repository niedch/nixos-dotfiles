{
  config,
  pkgs,
  lib,
  ...
}: let
  steamLauncher = pkgs.writeShellScriptBin "steam-launcher" ''
    # Apply Adwaita Steam theme headlessly before launching Steam
    ${pkgs.adwsteamgtk}/bin/adwaita-steam-gtk -i >/dev/null 2>&1 || true

    exec ${
      if config.hardware.nvidia.prime.offload.enable
      then "nvidia-offload "
      else ""
    }${pkgs.steam}/bin/steam "$@"
  '';

  patchDesktop = pkg: appName: from: to:
    lib.hiPrio (
      pkgs.runCommand "patched-desktop-entry-for-${appName}" {} ''
        ${pkgs.coreutils}/bin/mkdir -p $out/share/applications
        ${pkgs.gnused}/bin/sed 's#${from}#${to}#g' \
          < ${pkg}/share/applications/${appName}.desktop \
          > $out/share/applications/${appName}.desktop
      ''
    );
in {
  programs.steam = {
    enable = true;
    extraCompatPackages = [
      pkgs.proton-ge-bin
    ];
  };

  environment.systemPackages = [
    # Shadow steam command with wrapper script in PATH
    (lib.hiPrio (pkgs.writeShellScriptBin "steam" ''
      exec ${steamLauncher}/bin/steam-launcher "$@"
    ''))

    # Patch steam desktop entry to run steamLauncher
    (patchDesktop pkgs.steam "steam" "^Exec=.*" "Exec=${steamLauncher}/bin/steam-launcher %U")
  ];
}
