{
  config,
  pkgs,
  lib,
  ...
}: let
  # Valheim dedicated server Steam app id. Set to {id}_{branch}_{password} to
  # track a beta branch.
  steam-app = "896660";
  serverName = "Dobby";
  worldName = "Dedicated";

  # Reads the server password from the SOPS secret at runtime and launches the
  # dedicated server. The valheim user owns the secret so it can read it.
  startScript = pkgs.writeShellScript "valheim-server-start" ''
    password="$(< ${config.sops.secrets.VALHEIM_PASSWORD.path})"
    exec /var/lib/steam-app-${steam-app}/valheim_server.x86_64 \
      -nographics \
      -batchmode \
      -savedir /var/lib/valheim/save \
      -name ${lib.escapeShellArg serverName} \
      -port 2456 \
      -world ${lib.escapeShellArg worldName} \
      -password "$password" \
      -public 0 \
      -backups 0
  '';

  postStarted = pkgs.writeShellScript "valheim-backup-started" ''
    /run/current-system/sw/bin/post-homepage-message-board "Valheim backup started" info
  '';
  postDone = pkgs.writeShellScript "valheim-backup-done" ''
    /run/current-system/sw/bin/post-homepage-message-board "Valheim backup completed" success
  '';
  postFailed = pkgs.writeShellScript "valheim-backup-failed" ''
    /run/current-system/sw/bin/post-homepage-message-board "Valheim backup failed" error
  '';
in {
  imports = [
    ./steam.nix
  ];

  users.users.valheim = {
    isSystemUser = true;
    # Valheim puts save data in the home directory.
    home = "/var/lib/valheim";
    createHome = true;
    homeMode = "750";
    group = "valheim";
  };

  users.groups.valheim = {};

  # The valheim service runs as the `valheim` user, which needs to read this.
  sops.secrets.VALHEIM_PASSWORD = {
    owner = "valheim";
    group = "valheim";
    mode = "0400";
  };

  systemd.services.valheim = {
    wantedBy = ["multi-user.target"];

    # Install the game before launching.
    wants = ["steam@${steam-app}.service"];
    after = ["steam@${steam-app}.service"];

    environment = {
      # Valheim bundles its own shared libraries (Unity Mono runtime, Steamworks,
      # etc.) which resolve against these NixOS libraries on NixOS.
      LD_LIBRARY_PATH = lib.concatStringsSep ":" [
        "/var/lib/steam-app-${steam-app}/linux64"
        "${pkgs.glibc}/lib"
        "${pkgs.zlib}/lib"
        "${pkgs.stdenv.cc.cc.lib}/lib"
      ];
      SteamAppId = "892970";
    };

    serviceConfig = {
      ExecStart = startScript;
      Nice = "-5";
      PrivateTmp = true;
      Restart = "always";
      User = "valheim";
      WorkingDirectory = "/var/lib/valheim";
    };
  };

  networking.firewall = {
    # Valheim uses 2456 (game) and 2457 (Steam query) over both TCP and UDP.
    allowedTCPPorts = [2456 2457];
    allowedUDPPorts = [2456 2457];
  };

  # Back up the world save data. Reuses the shared RESTIC_PASSWORD secret
  # declared in modules/server/immich.nix.
  services.restic.backups.valheim = {
    repository = "/mnt/hdd/restic/restic-valheim";
    passwordFile = config.sops.secrets.RESTIC_PASSWORD.path;
    paths = ["/var/lib/valheim"];
    initialize = true;
    timerConfig = {
      OnCalendar = "17:30";
      Persistent = true;
      RandomizedDelaySec = "30m";
    };
    pruneOpts = [
      "--keep-daily 3"
      "--keep-weekly 2"
      "--keep-monthly 1"
    ];
  };

  systemd.services.restic-backups-valheim = {
    wants = ["message-board.service"];
    after = ["message-board.service"];
    onFailure = ["restic-backups-valheim-failure.service"];
    serviceConfig = {
      ExecStartPre = [postStarted];
      ExecStartPost = [postDone];
    };
  };

  systemd.services.restic-backups-valheim-failure = {
    description = "Post Valheim backup failure to message board";
    wants = ["message-board.service"];
    after = ["message-board.service"];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = postFailed;
    };
  };
}
