{pkgs}:
pkgs.writeShellScriptBin "opencode" ''
  export OPENCODE_CONFIG_DIR=${./config}
  export OPENCODE_DISABLE_AUTOUPDATE=1
  if [ -z "''${OPENCODE_GO:-}" ] && [ -r /run/secrets/OPENCODE_GO ]; then
    export OPENCODE_GO="$(cat /run/secrets/OPENCODE_GO)"
  fi
  exec ${pkgs.opencode}/bin/opencode "$@"
''
