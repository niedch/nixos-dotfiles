{
  config,
  pkgs,
  inputs,
  ...
}: let
  quickshell = import ./package.nix {inherit pkgs;};
in {
  imports = [./menu];

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
    libxkbcommon
    (pkgs.writeShellScriptBin "quickshell-reload-theme" ''
      QSID=$(env -u QS_CONFIG_PATH -u QS_CONFIG_NAME -u __QUICKSHELL_CRASH_INFO_FD -u __QUICKSHELL_CRASH_DUMP_PID -u __QUICKSHELL_CRASH_SIGNAL ${pkgs.quickshell}/bin/quickshell list --all 2>/dev/null | awk '/^Instance / {gsub(":", "", $2); print $2; exit}')
      if [ -n "$QSID" ]; then
        env -u QS_CONFIG_PATH -u QS_CONFIG_NAME -u __QUICKSHELL_CRASH_INFO_FD -u __QUICKSHELL_CRASH_DUMP_PID -u __QUICKSHELL_CRASH_SIGNAL ${pkgs.quickshell}/bin/quickshell ipc -i "$QSID" call theme-reload reload >/dev/null 2>&1 || true
      fi
    '')
    (pkgs.writeShellScriptBin "quickshell-launcher" ''
      QSID=$(env -u QS_CONFIG_PATH -u QS_CONFIG_NAME -u __QUICKSHELL_CRASH_INFO_FD -u __QUICKSHELL_CRASH_DUMP_PID -u __QUICKSHELL_CRASH_SIGNAL ${pkgs.quickshell}/bin/quickshell list --all 2>/dev/null | awk '/^Instance / {gsub(":", "", $2); print $2; exit}')
      if [ -n "$QSID" ]; then
        env -u QS_CONFIG_PATH -u QS_CONFIG_NAME -u __QUICKSHELL_CRASH_INFO_FD -u __QUICKSHELL_CRASH_DUMP_PID -u __QUICKSHELL_CRASH_SIGNAL ${pkgs.quickshell}/bin/quickshell ipc -i "$QSID" call launcher "$1" >/dev/null 2>&1 || true
      fi
    '')
    (pkgs.writeShellScriptBin "quickshell-notif" ''
      QSID=$(env -u QS_CONFIG_PATH -u QS_CONFIG_NAME -u __QUICKSHELL_CRASH_INFO_FD -u __QUICKSHELL_CRASH_DUMP_PID -u __QUICKSHELL_CRASH_SIGNAL ${pkgs.quickshell}/bin/quickshell list --all 2>/dev/null | awk '/^Instance / {gsub(":", "", $2); print $2; exit}')
      if [ -n "$QSID" ]; then
        env -u QS_CONFIG_PATH -u QS_CONFIG_NAME -u __QUICKSHELL_CRASH_INFO_FD -u __QUICKSHELL_CRASH_DUMP_PID -u __QUICKSHELL_CRASH_SIGNAL ${pkgs.quickshell}/bin/quickshell ipc -i "$QSID" call notifications "$1" >/dev/null 2>&1 || true
      fi
    '')
    (pkgs.writeShellScriptBin "quickshell-menu" ''
      QSID=$(env -u QS_CONFIG_PATH -u QS_CONFIG_NAME -u __QUICKSHELL_CRASH_INFO_FD -u __QUICKSHELL_CRASH_DUMP_PID -u __QUICKSHELL_CRASH_SIGNAL ${pkgs.quickshell}/bin/quickshell list --all 2>/dev/null | awk '/^Instance / {gsub(":", "", $2); print $2; exit}')
      if [ -n "$QSID" ]; then
        env -u QS_CONFIG_PATH -u QS_CONFIG_NAME -u __QUICKSHELL_CRASH_INFO_FD -u __QUICKSHELL_CRASH_DUMP_PID -u __QUICKSHELL_CRASH_SIGNAL ${pkgs.quickshell}/bin/quickshell ipc -i "$QSID" call menu "$1" >/dev/null 2>&1 || true
      fi
    '')
    (pkgs.writeShellScriptBin "theme-switcher-set" ''
      set -euo pipefail
      export DBUS_SESSION_BUS_ADDRESS="''${DBUS_SESSION_BUS_ADDRESS:-unix:path=/run/user/$(id -u)/bus}"
      export PATH="''${PATH:+$PATH:}$HOME/.nix-profile/bin:/etc/profiles/per-user/$USER/bin:/run/current-system/sw/bin"
      export GSETTINGS_SCHEMA_DIR="${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}/glib-2.0/schemas"
      THEME="$1"
      THEMES_DIR="$HOME/.local/share/themes"
      CURRENT="$THEMES_DIR/current"
      CURRENT_BG="$THEMES_DIR/current-background"
      HOOK_DIR="$HOME/.config/theme-switcher/hooks/theme-set.d"

      [ -z "$THEME" ] && exit 1
      [ ! -d "$THEMES_DIR/$THEME" ] && exit 1

      ln -sfn "$THEMES_DIR/$THEME" "$CURRENT"

      DEFAULT_BG=$(head -1 "$CURRENT/default-background" 2>/dev/null || echo "")
      FIRST_BG=$(ls -1 "$CURRENT/backgrounds/" 2>/dev/null | head -1 || echo "")
      BG="''${DEFAULT_BG:-$FIRST_BG}"
      [ -n "$BG" ] && ln -sfn "$CURRENT/backgrounds/$BG" "$CURRENT_BG"

      systemctl --user restart swaybg.service 2>/dev/null || true

      if [ -d "$HOOK_DIR" ]; then
        for hook in "$HOOK_DIR"/*; do
          [ -x "$hook" ] && "$hook" "$THEME" || true
        done
      fi
    '')
    (pkgs.writeShellScriptBin "background-set" ''
      set -euo pipefail
      BG="$1"
      BG_SRC="$HOME/.local/share/themes/current/backgrounds/$BG"
      CURRENT_BG="$HOME/.local/share/themes/current-background"

      [ -z "$BG" ] && exit 1
      [ ! -f "$BG_SRC" ] && exit 1

      ln -sfn "$BG_SRC" "$CURRENT_BG"
      systemctl --user restart swaybg.service
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
