{
  config,
  pkgs,
  inputs,
  ...
}: let
  quickshell = import ./package.nix {inherit pkgs;};
in {
  sops.secrets.CALENDAR_CONFIG = {
    path = "${config.home.homeDirectory}/.config/quickshell/calendars.txt";
    mode = "0600";
  };

  home.packages = with pkgs; [
    bluetui
    wiremix
    inputs.wlctl.packages.${pkgs.stdenv.hostPlatform.system}.default
    jq
    cava
    quickshell
    libqalculate
    cliphist
    (pkgs.writeShellScriptBin "quickshell-reload-theme" ''
      QSID=$(${pkgs.quickshell}/bin/quickshell list --all 2>/dev/null | awk '/^Instance / {gsub(":", "", $2); print $2; exit}')
      if [ -n "$QSID" ]; then
        ${pkgs.quickshell}/bin/quickshell ipc -i "$QSID" call theme-reload reload >/dev/null 2>&1 || true
      fi
    '')
    (pkgs.writeShellScriptBin "quickshell-launcher" ''
      QSID=$(${pkgs.quickshell}/bin/quickshell list --all 2>/dev/null | awk '/^Instance / {gsub(":", "", $2); print $2; exit}')
      if [ -n "$QSID" ]; then
        ${pkgs.quickshell}/bin/quickshell ipc -i "$QSID" call launcher "$1" >/dev/null 2>&1 || true
      fi
    '')
    (pkgs.writeShellScriptBin "quickshell-notif" ''
      QSID=$(${pkgs.quickshell}/bin/quickshell list --all 2>/dev/null | awk '/^Instance / {gsub(":", "", $2); print $2; exit}')
      if [ -n "$QSID" ]; then
        ${pkgs.quickshell}/bin/quickshell ipc -i "$QSID" call notifications "$1" >/dev/null 2>&1 || true
      fi
    '')
    (pkgs.writeShellScriptBin "calendar-sync" ''
      exec ${pkgs.python3.withPackages (ps: [ps.python-dateutil])}/bin/python3 ${./config}/scripts/calendar-sync.py "$@"
    '')
  ];

  xdg.configFile."quickshell/data/symbols.txt".source = ./config/data/symbols.txt;

  systemd.user.services.quickshell = {
    Unit = {
      Description = "Quickshell status bar";
      ConditionEnvironment = "WAYLAND_DISPLAY";
      After = ["hyprland-session.target"];
      PartOf = ["hyprland-session.target"];
    };
    Service = {
      ExecStart = "${quickshell}/bin/quickshell";
      Restart = "always";
      RestartSec = 2;
    };
    Install = {
      WantedBy = ["hyprland-session.target"];
    };
  };
}
