{
  pkgs,
  lib,
  plugins ? [],
}: let
  fetchPlugin = p:
    pkgs.fetchFromGitHub {
      owner = p.owner;
      repo = p.repo;
      rev = p.rev;
      sha256 = p.sha256;
    };

  # Create a merged config directory with plugins in Plugins/
  mergedConfig = pkgs.runCommand "quickshell-config" {} ''
    mkdir -p $out
    # Copy the original config
    cp -r ${./config}/* $out/
    chmod -R u+w $out

    # Install fetched plugins into Plugins/
    ${lib.concatMapStringsSep "\n" (p: ''
        ln -sf ${fetchPlugin p} $out/Plugins/${p.repo}
      '')
      plugins}
  '';

  qs-network-status = pkgs.writeShellScriptBin "qs-network-status" (builtins.readFile ./config/scripts/qs-network-status);
  qs-network-speedtest = pkgs.writeShellScriptBin "qs-network-speedtest" (builtins.readFile ./config/scripts/qs-network-speedtest);
  qs-dns = pkgs.writeShellScriptBin "qs-dns" (builtins.readFile ./config/scripts/qs-dns);
in
  pkgs.writeShellScriptBin "quickshell" ''
    export QS_CONFIG_PATH=${mergedConfig}
    export PATH="${qs-network-status}/bin:${qs-network-speedtest}/bin:${qs-dns}/bin:$PATH"
    exec ${pkgs.quickshell}/bin/quickshell "$@"
  ''
