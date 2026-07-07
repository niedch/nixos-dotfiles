{
  config,
  pkgs,
  ...
}: {
  services.immich = {
    enable = true;
    host = "0.0.0.0";
    openFirewall = true;
    mediaLocation = "/var/lib/immich";
  };
  services.redis.servers.immich.logLevel = "warning";

  services.postgresqlBackup = {
    enable = true;
    databases = ["immich"];
    compression = "zstd";
    compressionLevel = 6;
    startAt = "*-*-* 12:30:00";
  };

  services.restic.backups.immich = {
    repository = "/srv/samba/share/restic-immich";
    passwordFile = config.sops.secrets.RESTIC_PASSWORD.path;
    paths = [
      "/var/lib/immich"
      "/var/backup/postgresql"
    ];
    initialize = true;
    timerConfig = {
      OnCalendar = "13:00";
      Persistent = true;
      RandomizedDelaySec = "30m";
    };
    pruneOpts = [
      "--keep-daily 7"
      "--keep-weekly 4"
      "--keep-monthly 3"
    ];
  };

  systemd.services.restic-backups-immich = {
    after = ["postgresqlBackup.service"];
    requires = ["postgresqlBackup.service"];
  };

  sops.secrets.RESTIC_PASSWORD = {
    owner = "root";
    group = "root";
    mode = "0400";
  };
}
