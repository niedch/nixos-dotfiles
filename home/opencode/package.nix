{pkgs}:
pkgs.writeShellScriptBin "opencode" ''

  export OPENCODE_MAIN_MODEL=google/gemini-3.8-flash
  export OPENCODE_AGENT_MODEL=google/gemini-3.7-flash

  # export OPENCODE_MAIN_MODEL=opencode-go/deepseek-v4-pro
  # export OPENCODE_AGENT_MODEL=opencode-go/deepseek-v4-flash

  export OPENCODE_CONFIG_DIR=${./config}
  export OPENCODE_DISABLE_AUTOUPDATE=1
  if [ -z "''${OPENCODE_GO:-}" ] && [ -r /run/secrets/OPENCODE_GO ]; then
    export OPENCODE_GO="$(cat /run/secrets/OPENCODE_GO)"
  fi
  exec ${pkgs.opencode}/bin/opencode "$@"
''
