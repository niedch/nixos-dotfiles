{
  config,
  pkgs,
  ...
}: {
  sops.secrets.CALENDAR_CONFIG = {
    path = "${config.home.homeDirectory}/.config/quickshell/calendars.txt";
    mode = "0600";
  };

  home.packages = [
    pkgs.cava
    (import ./package.nix {inherit pkgs;})
    (pkgs.writeShellScriptBin "quickshell-reload-theme" ''
      QSID=$(${pkgs.quickshell}/bin/quickshell list --all 2>/dev/null | awk '/^Instance / {gsub(":", "", $2); print $2; exit}')
      if [ -n "$QSID" ]; then
        ${pkgs.quickshell}/bin/quickshell ipc -i "$QSID" call theme-reload reload >/dev/null 2>&1 || true
      fi
    '')
    (pkgs.writeShellScriptBin "calendar-sync" ''
      exec ${pkgs.python3.withPackages (ps: [ps.python-dateutil])}/bin/python3 ${./config}/scripts/calendar-sync.py "$@"
    '')
  ];
}
