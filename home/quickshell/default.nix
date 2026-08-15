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
