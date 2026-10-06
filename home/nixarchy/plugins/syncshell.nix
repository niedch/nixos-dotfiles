{
  pkgs,
  lib,
  ...
}: let
  raw = pkgs.fetchgit {
    name = "syncshell";
    url = "https://github.com/omarchy-QOL/syncshell.git";
    rev = "487cb557e20d4112560c6d9c51d7b204e1fc1068";
    hash = "sha256-KL/thX/7OeMqMsQYH108KR1ed5Xdoe9F4YA7SsgHePA=";
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
