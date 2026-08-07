{
  pkgs,
  mux-session,
}:
pkgs.writeShellScriptBin "mux-session" ''
  exec ${mux-session}/bin/mux-session -f ${./config.toml} "$@"
''
