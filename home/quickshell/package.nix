{pkgs}:
pkgs.writeShellScriptBin "quickshell" ''
  export QS_CONFIG_PATH=${./config}
  exec ${pkgs.quickshell}/bin/quickshell "$@"
''
