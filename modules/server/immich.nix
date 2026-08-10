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
  bindMountStart = pkgs.writeShellScript "immich-bind-mount-start" ''
    set -euo pipefail
    SRC_PREFIX="/var/lib/immich"
    DST_PREFIX="/mnt/hdd/immich"

    for DIR in thumbs encoded-video profile; do
      SRC="$SRC_PREFIX/$DIR"
      DST="$DST_PREFIX/$DIR"

      # Ensure target mount point exists on HDD
      mkdir -p "$DST"

      # Check if already mounted
      if mountpoint -q "$DST"; then
        echo "$DST is already a bind mount, skipping"
        continue
      fi

      # If DST has content, migrate it to SRC (one-time migration)
      if [ -d "$DST" ] && [ "$(ls -A "$DST" 2>/dev/null)" ]; then
        echo "Migrating existing $DIR data from HDD to SSD..."
        # Migrate regular items
        for item in "$DST"/*; do
          [ -e "$item" ] || continue
          name=$(basename "$item")
          if [ -e "$SRC/$name" ]; then
            echo "WARNING: $SRC/$name already exists, skipping $item"
          else
            mv "$item" "$SRC/"
          fi
        done
        # Migrate hidden items (but not . or ..)
        for item in "$DST"/.[!.]*; do
          [ -e "$item" ] || continue
          name=$(basename "$item")
          if [ "$name" = "." ] || [ "$name" = ".." ]; then
            continue
          fi
          if [ -e "$SRC/$name" ]; then
            echo "WARNING: $SRC/$name already exists, skipping $item"
          else
            mv "$item" "$SRC/"
          fi
        done
      fi

      # Bind mount SSD over HDD
      echo "Bind-mounting $SRC -> $DST"
      mount --bind "$SRC" "$DST"
    done
  '';

  bindMountStop = pkgs.writeShellScript "immich-bind-mount-stop" ''
    set -euo pipefail
    for DIR in thumbs encoded-video profile; do
      umount "/mnt/hdd/immich/$DIR" 2>/dev/null || true
    done
  '';
in {
  services.immich = {
    enable = true;
    host = "0.0.0.0";
    openFirewall = true;
    mediaLocation = "/mnt/hdd/immich";
  };
  services.redis.servers.immich.logLevel = "warning";

  systemd.services.immich-server = {
    after = ["immich-bind-mounts.service"];
    requires = ["immich-bind-mounts.service"];
    serviceConfig = {
      ReadWritePaths = [
        "/mnt/hdd/samba/immich-images"
        "/var/lib/immich"
      ];
      SupplementaryGroups = ["users"];
    };
  };

  systemd.services.immich-bind-mounts = {
    description = "Bind-mount Immich thumbs/encoded-video/profile to SSD";
    after = ["local-fs.target" "mnt-hdd.mount"];
    before = ["immich-server.service"];
    wantedBy = ["multi-user.target"];
    path = [pkgs.util-linux pkgs.coreutils];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = bindMountStart;
      ExecStop = bindMountStop;
    };
  };

  systemd.tmpfiles.rules = [
    "d /mnt/hdd/samba/immich-images 0770 nic users - -"
    "d /mnt/hdd/samba/immich-images/nic 0770 nic users - -"
    "d /mnt/hdd/samba/immich-images/melio 0770 nic users - -"
    "d /mnt/hdd/samba/immich-images/poldi 0770 nic users - -"
    "d /var/lib/immich/thumbs 0750 immich immich - -"
    "d /var/lib/immich/encoded-video 0750 immich immich - -"
    "d /var/lib/immich/profile 0750 immich immich - -"
  ];

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
      "/mnt/hdd/samba/immich-images"
      "/var/backup/postgresql"
      "/var/lib/immich"
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

  systemd.services.immich-library-setup = {
    description = "Create Immich external library for Samba share";
    after = ["network.target" "immich-server.service"];
    wants = ["immich-server.service"];
    wantedBy = ["multi-user.target"];
    unitConfig.ConditionPathExists = config.sops.secrets.IMMICH_API_KEY.path;
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = "yes";
    };
    path = [pkgs.curl pkgs.jq];
    script = ''
      API_KEY="$(cat ${config.sops.secrets.IMMICH_API_KEY.path})"
      BASE="http://127.0.0.1:2283/api"

      # Wait for immich-server to be ready (Type=simple, no readiness signal)
      for i in $(seq 1 30); do
        if curl -sf -H "x-api-key: $API_KEY" "$BASE/server/ping" >/dev/null 2>&1; then
          break
        fi
        sleep 2
      done

      # Per-user external libraries
      setup_library() {
        local NAME="$1"
        local OWNER_ID="$2"
        local IMPORT_PATH="$3"

        # Check if library already exists (idempotent)
        LIB_ID=$(curl -sf -H "x-api-key: $API_KEY" "$BASE/libraries" \
          | jq -r --arg name "$NAME" '.[] | select(.name == $name) | .id')

        if [ -z "$LIB_ID" ]; then
          echo "Creating external library '$NAME'..."
          LIB_ID=$(curl -sf -X POST \
            -H "x-api-key: $API_KEY" \
            -H "Content-Type: application/json" \
            -d "{\"ownerId\":\"$OWNER_ID\",\"name\":\"$NAME\",\"importPaths\":[\"$IMPORT_PATH\"]}" \
            "$BASE/libraries" | jq -r .id)
          if [ -z "$LIB_ID" ] || [ "$LIB_ID" = "null" ]; then
            echo "ERROR: Failed to create library '$NAME'" >&2
            exit 1
          fi
          echo "Library created: $LIB_ID"
        else
          echo "Library '$NAME' already exists: $LIB_ID"
        fi

        # Trigger scan
        echo "Scanning library..."
        curl -sf -X POST -H "x-api-key: $API_KEY" "$BASE/libraries/$LIB_ID/scan" >/dev/null
        echo "Scan triggered for library $LIB_ID"
      }

      setup_library "nic" "34948c21-a55d-4a97-b9cb-e1896cb5c0b0" "/mnt/hdd/samba/immich-images/nic"
      setup_library "meli" "463efc62-b1f1-4e52-9e61-504e59464a5a" "/mnt/hdd/samba/immich-images/melio"
      setup_library "poldi" "462beaa3-8d60-4227-befd-a1e530cba72d" "/mnt/hdd/samba/immich-images/poldi"
    '';
  };

  sops.secrets.RESTIC_PASSWORD = {
    owner = "root";
    group = "root";
    mode = "0400";
  };

  sops.secrets.IMMICH_API_KEY = {
    owner = "root";
    group = "root";
    mode = "0400";
  };
}
