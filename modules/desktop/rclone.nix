{
  config,
  pkgs,
  lib,
  ...
}: let
  mounts = [
    {
      name = "G-Drive";
      remote = "G-Drive:Documents";
      mountPoint = "/media/Google-Drive";
    }
    {
      name = "I-Cloud";
      remote = "Icloud:";
      mountPoint = "/media/ICloud";
    }
    {
      name = "Dropbox";
      remote = "Dropbox:";
      mountPoint = "/media/Dropbox";
    }
  ];

  # network-online.target only guarantees an interface is up, not that DNS
  # resolution works. rclone's first action is an OAuth token refresh that
  # fails with "no such host" if name resolution isn't ready yet (e.g. right
  # after NetworkManager is restarted during a switch), so wait until it is.
  waitForDns = pkgs.writeShellApplication {
    name = "rclone-wait-for-dns";
    runtimeInputs = [
      pkgs.getent
      pkgs.coreutils
    ];
    text = ''
      i=0
      while [ "$i" -lt 90 ]; do
        if getent ahosts oauth2.googleapis.com >/dev/null 2>&1; then
          exit 0
        fi
        sleep 1
        i=$((i + 1))
      done
      echo "rclone-wait-for-dns: DNS still unavailable after 90s" >&2
      exit 1
    '';
  };
in
  lib.mkIf config.sops.enable {
    environment.systemPackages = [pkgs.rclone];

    systemd.services = builtins.listToAttrs (map (mount: {
        name = "rclone-mount-${mount.name}";
        value = {
          description = "rclone mount service (${mount.name})";
          after = ["network-online.target"];
          wants = ["network-online.target"];
          wantedBy = ["multi-user.target"];

          serviceConfig = {
            Type = "simple";
            ExecStartPre = [
              "${pkgs.coreutils}/bin/mkdir -p ${mount.mountPoint}"
              "${lib.getExe waitForDns}"
            ];
            ExecStart = "${pkgs.rclone}/bin/rclone mount ${mount.remote} ${mount.mountPoint} --config ${config.sops.secrets.rclone-config.path} --allow-other --vfs-cache-mode writes --dir-perms 0755 --file-perms 0644";
            ExecStop = "${pkgs.fuse3}/bin/fusermount3 -u ${mount.mountPoint}";
            Restart = "on-failure";
            RestartSec = "10s";
            TimeoutStartSec = "120s";
          };
        };
      })
      mounts);
  }
