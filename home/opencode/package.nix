{pkgs}:
pkgs.writeShellScriptBin "opencode" ''
  export OPENCODE_CONFIG_DIR=${./config}
  export OPENCODE_DISABLE_AUTOUPDATE=1
  exec ${pkgs.opencode}/bin/opencode "$@"
''
