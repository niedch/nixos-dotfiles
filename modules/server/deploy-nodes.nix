{
  config,
  lib,
  pkgs,
  inputs ? { },
  ...
}:
let
  cfg = config.services.deploy-nodes;
  deployPkg = inputs.deploy-rs.packages.${pkgs.system}.default or pkgs.deploy-rs;
in
{
  options.services.deploy-nodes = {
    enable = lib.mkEnableOption "automated deploy-rs systemd services";

    nodes = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "raspberry-pi"
        "dobby"
        "desktop"
      ];
      description = "List of node names from deploy.nix to deploy.";
    };

    flake = lib.mkOption {
      type = lib.types.str;
      default = "github:niedch/nixos-dotfiles";
      description = "Flake URI to deploy.";
    };

    schedule = lib.mkOption {
      type = lib.types.str;
      default = "04:00";
      description = "systemd OnCalendar schedule string.";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services = lib.mkMerge (
      map (node: {
        "deploy-node-${node}" = {
          description = "Automated deploy-rs deployment for node ${node}";
          wants = [ "network-online.target" ];
          after = [ "network-online.target" ];
          onFailure = [ "deploy-node-${node}-failure.service" ];
          path = [
            deployPkg
            pkgs.nix
            pkgs.openssh
            pkgs.git
            pkgs.coreutils
          ];
          serviceConfig = {
            Type = "oneshot";
            User = "nic";
            Group = "users";
            KillMode = "process";
            TimeoutSec = "45m";
            Environment = [ "HOME=/home/nic" "NIX_SSHOPTS=-o StrictHostKeyChecking=accept-new" ];
            ExecStartPre = [
              (pkgs.writeShellScript "notify-deploy-${node}-start" "/run/current-system/sw/bin/post-homepage-message-board 'Deploying ${node} started' info")
            ];
            ExecStart = "${deployPkg}/bin/deploy ${cfg.flake}#${node} -- --accept-flake-config";
            ExecStartPost = [
              (pkgs.writeShellScript "notify-deploy-${node}-success" "/run/current-system/sw/bin/post-homepage-message-board 'Deploying ${node} completed' success")
            ];
          };
        };

        "deploy-node-${node}-failure" = {
          description = "Notify dashboard of deployment failure for ${node}";
          wants = [ "network-online.target" ];
          after = [ "network-online.target" ];
          serviceConfig = {
            Type = "oneshot";
            User = "nic";
            ExecStart = pkgs.writeShellScript "notify-deploy-${node}-failure" "/run/current-system/sw/bin/post-homepage-message-board 'Deploying ${node} failed' error";
          };
        };
      }) cfg.nodes
    );

    systemd.timers = lib.mkMerge (
      map (node: {
        "deploy-node-${node}" = {
          description = "Timer for automated deployment of node ${node}";
          wantedBy = [ "timers.target" ];
          timerConfig = {
            OnCalendar = cfg.schedule;
            Persistent = true;
            RandomizedDelaySec = "15m";
          };
        };
      }) cfg.nodes
    );

    systemd.tmpfiles.rules = lib.mkIf (config.sops.secrets ? id_ed25519) [
      "d /home/nic/.ssh 0700 nic users -"
      "L+ /home/nic/.ssh/id_ed25519 - - - - ${config.sops.secrets.id_ed25519.path}"
    ];
  };
}
