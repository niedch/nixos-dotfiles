{
  pkgs,
  lib,
  ...
}: let
  raw = pkgs.fetchgit {
    name = "syncshell";
    url = "https://github.com/omarchy-QOL/syncshell.git";
    rev = "3cd6060132550f63fd4636d6519081275793cfd9";
    hash = "sha256-8bmqv5wbbU3WHRjmZjoUZtlO0XzVphISEWDeJeBqtyM=";
  };
in {
  # The bundled Go core is statically linked and runs on NixOS, but it is
  # reached through two FHS assumptions that don't hold here:
  #   - shared/CoreProcess.qml launches bin/syncshell-core (a bash dispatcher
  #     with #!/bin/bash + /usr/bin/uname), and probes it with /usr/bin/find.
  # Point the core straight at the x86_64 binary and resolve find via Nix.
  programs.nixarchy.plugins.syncthing.src = pkgs.stdenvNoCC.mkDerivation {
    name = "syncshell-plugin";
    src = raw;
    dontUnpack = true;
    dontPatch = true;
    dontConfigure = true;
    dontBuild = true;
    installPhase = ''
      mkdir -p "$out"
      cp -r "$src/." "$out"
      chmod -R u+w "$out"
      substituteInPlace "$out/shared/CoreProcess.qml" \
        --replace-fail 'Qt.resolvedUrl("../bin/syncshell-core")' \
                        'Qt.resolvedUrl("../bin/x86_64/syncshell-core")' \
        --replace-fail "/usr/bin/find" "${pkgs.findutils}/bin/find"
    '';
  };
}
