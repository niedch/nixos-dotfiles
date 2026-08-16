{
  pkgs,
  lib,
  plugins ? [],
}: let
  fetchPlugin = p:
    pkgs.fetchFromGitHub {
      owner = p.owner;
      repo = p.repo;
      rev = p.rev;
      sha256 = p.sha256;
    };

  # Create a merged config directory with plugins in Plugins/
  mergedConfig = pkgs.runCommand "quickshell-config" {} ''
    mkdir -p $out
    # Copy the original config
    cp -r ${./config}/* $out/
    chmod -R u+w $out
    chmod +x $out/Plugins/Clipboard/capture.sh

    # Install fetched plugins into Plugins/
    ${lib.concatMapStringsSep "\n" (p: ''
        ln -sf ${fetchPlugin p} $out/Plugins/${p.repo}
      '')
      plugins}
  '';

  qs-network-status = pkgs.writeShellScriptBin "qs-network-status" (builtins.readFile ./config/scripts/qs-network-status);
  qs-network-speedtest = pkgs.writeShellScriptBin "qs-network-speedtest" (builtins.readFile ./config/scripts/qs-network-speedtest);
  qs-dns = pkgs.writeShellScriptBin "qs-dns" (builtins.readFile ./config/scripts/qs-dns);
  omarchy-battery-status = pkgs.writeShellScriptBin "omarchy-battery-status" (builtins.readFile ./config/scripts/omarchy-battery-status);
  omarchy-monitor-state = pkgs.writeShellScriptBin "omarchy-monitor-state" (builtins.readFile ./config/scripts/omarchy-monitor-state);
  omarchy-brightness-display = pkgs.writeShellScriptBin "omarchy-brightness-display" (builtins.readFile ./config/scripts/omarchy-brightness-display);
  omarchy-hyprland-monitor-scaling = pkgs.writeShellScriptBin "omarchy-hyprland-monitor-scaling" (builtins.readFile ./config/scripts/omarchy-hyprland-monitor-scaling);
  omarchy-hyprland-monitor-focused = pkgs.writeShellScriptBin "omarchy-hyprland-monitor-focused" (builtins.readFile ./config/scripts/omarchy-hyprland-monitor-focused);
  omarchy-hw-display = pkgs.writeShellScriptBin "omarchy-hw-display" (builtins.readFile ./config/scripts/omarchy-hw-display);
  omarchy-osd = pkgs.writeShellScriptBin "omarchy-osd" (builtins.readFile ./config/scripts/omarchy-osd);
  qs-volume = pkgs.writeShellScriptBin "qs-volume" (builtins.readFile ./config/scripts/qs-volume);
  omarchy-clipboard-paste-text = pkgs.writeShellScriptBin "omarchy-clipboard-paste-text" (builtins.readFile ./config/scripts/omarchy-clipboard-paste-text);
  omarchy-clipboard-paste-file = pkgs.writeShellScriptBin "omarchy-clipboard-paste-file" (builtins.readFile ./config/scripts/omarchy-clipboard-paste-file);
  omarchy-clipboard-open = pkgs.writeShellScriptBin "omarchy-clipboard-open" (builtins.readFile ./config/scripts/omarchy-clipboard-open);
  omarchy-reminder = pkgs.writeShellScriptBin "omarchy-reminder" (builtins.readFile ./config/scripts/omarchy-reminder);
  omarchy-notification-send = pkgs.writeShellScriptBin "omarchy-notification-send" (builtins.readFile ./config/scripts/omarchy-notification-send);
in
  pkgs.writeShellScriptBin "quickshell" ''
    export QS_CONFIG_PATH=${mergedConfig}
    export PATH="${qs-network-status}/bin:${qs-network-speedtest}/bin:${qs-dns}/bin:${omarchy-battery-status}/bin:${omarchy-monitor-state}/bin:${omarchy-brightness-display}/bin:${omarchy-hyprland-monitor-scaling}/bin:${omarchy-hyprland-monitor-focused}/bin:${omarchy-hw-display}/bin:${omarchy-osd}/bin:${qs-volume}/bin:${omarchy-clipboard-paste-text}/bin:${omarchy-clipboard-paste-file}/bin:${omarchy-clipboard-open}/bin:${omarchy-reminder}/bin:${omarchy-notification-send}/bin:$PATH"
    exec ${pkgs.quickshell}/bin/quickshell "$@"
  ''
