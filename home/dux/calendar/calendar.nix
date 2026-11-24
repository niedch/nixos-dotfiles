{
  config,
  pkgs,
  lib,
  ...
}:
let
  dcalBin = lib.getExe config.programs.dank-calendar.package;
  secretPath = config.sops.secrets.CALENDAR_CONFIG.path;

  syncCalendarScript = pkgs.writeShellScriptBin "dcal-sync-calendar-accounts" ''
    export DCAL="${dcalBin}"
    export SECRET_PATH="${secretPath}"
    exec ${pkgs.python3}/bin/python3 ${./dcal-sync-calendar-accounts.py}
  '';
in
{
  sops.secrets.CALENDAR_CONFIG = {};

  home.packages = [ syncCalendarScript ];

  programs.dank-calendar = {
    enable = true;
    systemd = {
      enable = true;
      restartIfChanged = true;
    };
  };

  systemd.user.services.dcal-sync-calendar-accounts = {
    Unit = {
      Description = "Sync calendar accounts from SOPS secret to dcal";
      After = [ "sops-nix.service" ];
      Wants = [ "sops-nix.service" ];
      PartOf = [ config.programs.dank-calendar.systemd.target ];
    };

    Service = {
      Type = "oneshot";
      ExecStart = "${lib.getExe syncCalendarScript}";
      RemainAfterExit = true;
    };

    Install = {
      WantedBy = [ config.programs.dank-calendar.systemd.target ];
    };
  };

  home.activation.dcalSyncAccounts = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if [ -r "${secretPath}" ]; then
      ${lib.getExe syncCalendarScript} || true
    fi
  '';
}
