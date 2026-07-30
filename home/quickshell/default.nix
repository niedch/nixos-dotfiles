{pkgs, ...}: let
  configDir = ./config;

  quickshellWrapped = pkgs.writeShellScriptBin "quickshell" ''
    export QS_CONFIG_PATH=${configDir}
    export QSR_CONFIG=${configDir}/shell.qml
    export QSR_QS_BIN=${pkgs.quickshell}/bin/quickshell
    exec ${pkgs.quickshell}/bin/quickshell "$@"
  '';

  qs-barctl = pkgs.writeShellScriptBin "qs-barctl" ''
    export QS_CONFIG_PATH=${configDir}
    export QSR_CONFIG=${configDir}/shell.qml
    export QSR_QS_BIN=${pkgs.quickshell}/bin/quickshell
    exec ${./scripts/qs-barctl} "$@"
  '';

  qs-proj = pkgs.writeShellScriptBin "qs-proj" ''
    export QS_CONFIG_PATH=${configDir}
    export QSR_CONFIG=${configDir}/shell.qml
    export QSR_QS_BIN=${pkgs.quickshell}/bin/quickshell
    export QS_BARCTL=${qs-barctl}/bin/qs-barctl
    exec ${./scripts/qs-proj} "$@"
  '';

  claude-usage = pkgs.runCommand "claude-usage" { } ''
    install -Dm755 ${./scripts/claude-usage} $out/bin/claude-usage
  '';
  codex-usage = pkgs.runCommand "codex-usage" { } ''
    install -Dm755 ${./scripts/codex-usage} $out/bin/codex-usage
  '';
  opencode-usage = pkgs.runCommand "opencode-usage" { } ''
    install -Dm755 ${./scripts/opencode-usage} $out/bin/opencode-usage
  '';
in {
  # Runtime dependencies are provided by other modules:
  #   pkgs.ghostty          home/ghostty/
  #   pkgs.pamixer          home/waybar/
  #   pkgs.wireplumber      system (pipewire)
  #   pkgs.wiremix          home/waybar/
  #   pkgs.brightnessctl    home/hyprland/
  #   pkgs.upower           system
  #   pkgs.libnotify        system
  #   pkgs.btop             home/tools/btop.nix
  #   pkgs.cava             home/tools/
  #   pkgs.mako             home/hyprland/services.nix
  #   pkgs.wf-recorder      home/tools/
  #   pkgs.bluetui          home/waybar/
  #   pkgs.weathr           home/desktop.nix
  #   pkgs.jq               system
  #   pkgs.curl             system
  #   pkgs.bash             system
  #   inputs.wlctl          home/waybar/
  home.packages = [
    quickshellWrapped
    qs-barctl
    qs-proj
    claude-usage
    codex-usage
    opencode-usage
  ];

  systemd.user.services."claude-usage" = {
    Unit = { Description = "Claude Code usage (OAuth, feeds the Quickshell quota widget)"; };
    Service = {
      Type = "oneshot";
      ExecStart = "${claude-usage}/bin/claude-usage";
      StandardOutput = "journal";
      StandardError = "journal";
    };
  };
  systemd.user.timers."claude-usage" = {
    Unit = {
      Description = "Claude Code usage refresh (every 5 min)";
      Requires = ["claude-usage.service"];
    };
    Timer = {
      OnBootSec = "30";
      OnUnitActiveSec = "5min";
      AccuracySec = "30s";
      Persistent = false;
    };
    Install = { WantedBy = ["timers.target"]; };
  };

  systemd.user.services."codex-usage" = {
    Unit = { Description = "OpenAI Codex usage (app-server RPC, feeds the Quickshell quota widget)"; };
    Service = {
      Type = "oneshot";
      ExecStart = "${codex-usage}/bin/codex-usage";
      StandardOutput = "journal";
      StandardError = "journal";
    };
  };
  systemd.user.timers."codex-usage" = {
    Unit = {
      Description = "OpenAI Codex usage refresh (every 5 min)";
      Requires = ["codex-usage.service"];
    };
    Timer = {
      OnBootSec = "45";
      OnUnitActiveSec = "5min";
      AccuracySec = "30s";
      Persistent = false;
    };
    Install = { WantedBy = ["timers.target"]; };
  };

  systemd.user.services."opencode-usage" = {
    Unit = { Description = "OpenCode local usage (SQLite, feeds the Quickshell AI usage widget)"; };
    Service = {
      Type = "oneshot";
      ExecStart = "${opencode-usage}/bin/opencode-usage";
      StandardOutput = "journal";
      StandardError = "journal";
    };
  };
  systemd.user.timers."opencode-usage" = {
    Unit = {
      Description = "OpenCode usage refresh (every 5 min)";
      Requires = ["opencode-usage.service"];
    };
    Timer = {
      OnBootSec = "45";
      OnUnitActiveSec = "5min";
      AccuracySec = "30s";
      Persistent = false;
    };
    Install = { WantedBy = ["timers.target"]; };
  };
}
