{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.quickshell;
  quickshell = import ./package.nix {
    inherit pkgs lib;
    plugins = cfg.plugins;
  };
in {
  imports = [./menu ./plugins.nix];

  options.quickshell.plugins = lib.mkOption {
    type = lib.types.listOf (lib.types.submodule {
      options = {
        owner = lib.mkOption {
          type = lib.types.str;
          description = "GitHub repository owner";
          example = "dhh";
        };
        repo = lib.mkOption {
          type = lib.types.str;
          description = "GitHub repository name";
          example = "omarchy-clock-plugin";
        };
        rev = lib.mkOption {
          type = lib.types.str;
          description = "Git revision (commit hash or tag)";
          example = "v1.0.0";
        };
        sha256 = lib.mkOption {
          type = lib.types.str;
          description = "Nix hash of the fetched source";
          example = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
        };
      };
    });
    default = [];
    description = "External quickshell plugins to fetch from GitHub and install";
  };

  config = {
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
      upower
      wtype
      wl-clipboard
      procps
      util-linux
      voxtype
      quickshell
      libqalculate
      cliphist
      libxkbcommon
      curl
      (pkgs.writeShellScriptBin "qs-network-status" (builtins.readFile ./config/scripts/qs-network-status))
      (pkgs.writeShellScriptBin "qs-network-speedtest" (builtins.readFile ./config/scripts/qs-network-speedtest))
      (pkgs.writeShellScriptBin "qs-dns" (builtins.readFile ./config/scripts/qs-dns))
      (pkgs.writeShellScriptBin "omarchy-battery-status" (builtins.readFile ./config/scripts/omarchy-battery-status))
      (pkgs.writeShellScriptBin "omarchy-monitor-state" (builtins.readFile ./config/scripts/omarchy-monitor-state))
      (pkgs.writeShellScriptBin "omarchy-brightness-display" (builtins.readFile ./config/scripts/omarchy-brightness-display))
      (pkgs.writeShellScriptBin "omarchy-hyprland-monitor-scaling" (builtins.readFile ./config/scripts/omarchy-hyprland-monitor-scaling))
      (pkgs.writeShellScriptBin "omarchy-hyprland-monitor-focused" (builtins.readFile ./config/scripts/omarchy-hyprland-monitor-focused))
      (pkgs.writeShellScriptBin "omarchy-hw-display" (builtins.readFile ./config/scripts/omarchy-hw-display))
      (pkgs.writeShellScriptBin "omarchy-osd" (builtins.readFile ./config/scripts/omarchy-osd))
      (pkgs.writeShellScriptBin "qs-volume" (builtins.readFile ./config/scripts/qs-volume))
      (pkgs.writeShellScriptBin "omarchy-clipboard-paste-text" (builtins.readFile ./config/scripts/omarchy-clipboard-paste-text))
      (pkgs.writeShellScriptBin "omarchy-clipboard-paste-file" (builtins.readFile ./config/scripts/omarchy-clipboard-paste-file))
      (pkgs.writeShellScriptBin "omarchy-clipboard-open" (builtins.readFile ./config/scripts/omarchy-clipboard-open))
      (pkgs.writeShellScriptBin "omarchy-reminder" (builtins.readFile ./config/scripts/omarchy-reminder))
      (pkgs.writeShellScriptBin "omarchy-notification-send" (builtins.readFile ./config/scripts/omarchy-notification-send))
      (pkgs.writeShellScriptBin "omarchy-launch-browser" ''
        exec ${pkgs.xdg-utils}/bin/xdg-open "$@"
      '')
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
      (pkgs.writeShellScriptBin "quickshell-opencode-refresh" ''
        QSID=$(env -u QS_CONFIG_PATH -u QS_CONFIG_NAME -u __QUICKSHELL_CRASH_INFO_FD -u __QUICKSHELL_CRASH_DUMP_PID -u __QUICKSHELL_CRASH_SIGNAL ${pkgs.quickshell}/bin/quickshell list --all 2>/dev/null | awk '/^Instance / {gsub(":", "", $2); print $2; exit}')
        if [ -n "$QSID" ]; then
          env -u QS_CONFIG_PATH -u QS_CONFIG_NAME -u __QUICKSHELL_CRASH_INFO_FD -u __QUICKSHELL_CRASH_DUMP_PID -u __QUICKSHELL_CRASH_SIGNAL ${pkgs.quickshell}/bin/quickshell ipc -i "$QSID" call opencode-refresh refresh >/dev/null 2>&1 || true
        fi
      '')
      (pkgs.writeShellScriptBin "calendar-sync" ''
        exec ${pkgs.python3.withPackages (ps: [ps.python-dateutil])}/bin/python3 ${./config}/scripts/calendar-sync.py "$@"
      '')
      (pkgs.writeShellScriptBin "quickshell-plugin-rescan" ''
        QSID=$(env -u QS_CONFIG_PATH -u QS_CONFIG_NAME -u __QUICKSHELL_CRASH_INFO_FD -u __QUICKSHELL_CRASH_DUMP_PID -u __QUICKSHELL_CRASH_SIGNAL ${pkgs.quickshell}/bin/quickshell list --all 2>/dev/null | awk '/^Instance / {gsub(":", "", $2); print $2; exit}')
        if [ -n "$QSID" ]; then
          env -u QS_CONFIG_PATH -u QS_CONFIG_NAME -u __QUICKSHELL_CRASH_INFO_FD -u __QUICKSHELL_CRASH_DUMP_PID -u __QUICKSHELL_CRASH_SIGNAL ${pkgs.quickshell}/bin/quickshell ipc -i "$QSID" call shell rescanPlugins >/dev/null 2>&1 || true
        fi
      '')
      (pkgs.writeShellScriptBin "quickshell-shell" ''
        # Default the JSON payload to {} for summon/toggle when omitted.
        case "$1" in
          summon|toggle)
            if [ $# -eq 2 ]; then
              set -- "$1" "$2" "{}"
            fi
            ;;
        esac
        quickshell ipc call shell "$@" >/dev/null 2>&1 || true
      '')
    ];

    xdg.configFile = {
      "quickshell/data/symbols.txt".source = ./config/data/symbols.txt;
      "quickshell/shell.json".source = ./config/shell.json;
    };

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
        KillMode = "process";
        SendSIGKILL = "no";
      };
      Install = {
        WantedBy = ["hyprland-session.target"];
      };
    };
  };
}
