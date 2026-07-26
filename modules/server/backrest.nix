{pkgs, ...}: {
  systemd.services.backrest = {
    description = "Backrest - Web UI and orchestrator for restic backup";
    after = ["network.target"];
    wantedBy = ["multi-user.target"];

    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.backrest}/bin/backrest";
      Restart = "on-failure";
      RestartSec = "5s";

      StateDirectory = "backrest";
      StateDirectoryMode = "0700";

      Environment = [
        "BACKREST_DATA=/var/lib/backrest"
        "BACKREST_CONFIG=/var/lib/backrest/config.json"
        "BACKREST_RESTIC_COMMAND=${pkgs.restic}/bin/restic"
        "BACKREST_PORT=0.0.0.0:9898"
      ];
    };
  };

  networking.firewall.allowedTCPPorts = [9898];
}
