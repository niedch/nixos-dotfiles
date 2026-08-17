{
  config,
  pkgs,
  lib,
  ...
}: let
  # Downloads a Steam app via steamcmd and patches the ELF interpreter so the
  # downloaded binaries run on NixOS. Instantiated as `steam@<instance>` where
  # the instance is `{app-id}_{beta}_{beta-password}` (see steam@ below).
  steamDownload = pkgs.writeShellScript "steam-download" ''
    set -eux

    instance="''${1:?Instance Missing}"
    IFS='_' read -r -a args <<< "$instance"
    app="''${args[0]:?App ID missing}"
    beta="''${args[1]:-}"
    betapass="''${args[2]:-}"

    dir="/var/lib/steam-app-$instance"

    cmds=(
      +force_install_dir "$dir"
      +login anonymous
      +app_update "$app" validate
    )

    if [[ -n "$beta" ]]; then
      cmds+=(-beta "$beta")
      if [[ -n "$betapass" ]]; then
        cmds+=(-betapassword "$betapass")
      fi
    fi

    cmds+=(+quit)

    steamcmd "''${cmds[@]}"

    for f in "$dir"/*; do
      if [[ -f "$f" && -x "$f" ]]; then
        patchelf --set-interpreter ${pkgs.glibc}/lib/ld-linux-x86-64.so.2 "$f" || true
      fi
    done
  '';
in {
  # nixpkgs' steamcmd fetches its source from web.archive.org, which is often
  # unavailable (HTTP 503). Steam's CDN serves the identical tarball, so
  # override the source URL to point at it directly.
  nixpkgs.overlays = [
    (final: prev: {
      steamcmd = prev.steamcmd.overrideAttrs (old: {
        src = prev.fetchurl {
          url = "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz";
          hash = "sha256-zr8ARr/QjPRdprwJSuR6o56/QVXl7eQTc7V5uPEHHnw=";
        };
      });
    })
  ];

  users.users.steam = {
    isSystemUser = true;
    group = "steam";
    home = "/var/lib/steam";
    createHome = true;
  };

  users.groups.steam = {};

  systemd.services."steam@" = {
    unitConfig = {
      StopWhenUnneeded = true;
    };
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${steamDownload} %i";
      PrivateTmp = true;
      Restart = "on-failure";
      StateDirectory = "steam-app-%i";
      TimeoutStartSec = 7200;
      User = "steam";
      WorkingDirectory = "~";
    };
    path = [pkgs.steamcmd pkgs.patchelf];
  };
}
