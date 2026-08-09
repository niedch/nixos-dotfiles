{
  config,
  pkgs,
  ...
}: let
  postStarted = pkgs.writeShellScript "immich-backup-started" ''
    /run/current-system/sw/bin/post-homepage-message-board "Immich backup started" info
  '';
  postDone = pkgs.writeShellScript "immich-backup-done" ''
    /run/current-system/sw/bin/post-homepage-message-board "Immich backup completed" success
  '';
  postFailed = pkgs.writeShellScript "immich-backup-failed" ''
    /run/current-system/sw/bin/post-homepage-message-board "Immich backup failed" error
  '';
in {
  services.immich = {
    enable = true;
    host = "0.0.0.0";
    openFirewall = true;
    mediaLocation = "/mnt/hdd/immich";
  };
  services.redis.servers.immich.logLevel = "warning";

  services.postgresqlBackup = {
    enable = true;
    databases = ["immich"];
    compression = "zstd";
    compressionLevel = 6;
    startAt = "*-*-* 16:50:00";
  };

  services.restic.backups.immich = {
    repository = "/mnt/hdd/restic/restic-immich";
    passwordFile = config.sops.secrets.RESTIC_PASSWORD.path;
    paths = [
      "/mnt/hdd/immich"
      "/var/backup/postgresql"
    ];
    initialize = true;
    timerConfig = {
      OnCalendar = "17:10";
      Persistent = true;
      RandomizedDelaySec = "30m";
    };
    pruneOpts = [
      "--keep-daily 3"
      "--keep-weekly 2"
      "--keep-monthly 1"
    ];
  };

  systemd.services.restic-backups-immich = {
    after = ["postgresqlBackup-immich.service" "message-board.service"];
    requires = ["postgresqlBackup-immich.service"];
    wants = ["message-board.service"];
    onFailure = ["restic-backups-immich-failure.service"];
    serviceConfig = {
      ExecStartPre = [postStarted];
      ExecStartPost = [postDone];
    };
  };

  systemd.services.restic-backups-immich-failure = {
    description = "Post immich backup failure to message board";
    after = ["message-board.service"];
    wants = ["message-board.service"];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = postFailed;
    };
  };

  sops.secrets.RESTIC_PASSWORD = {
    owner = "root";
    group = "root";
    mode = "0400";
  };
}
