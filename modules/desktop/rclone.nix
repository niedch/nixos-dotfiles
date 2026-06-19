{config, pkgs, ...}: let
  mounts = [
    {
      name = "G-Drive";
      remote = "G-Drive:Documents";
      mountPoint = "/media/Google-Drive";
    }
    {
      name = "I-Cloud";
      remote = "Icloud:";
      mountPoint = "/media/Icloud";
    }
  ];
in {
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
        ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p ${mount.mountPoint}";
        ExecStart = "${pkgs.rclone}/bin/rclone mount ${mount.remote} ${mount.mountPoint} --config ${config.sops.secrets.rclone-config.path} --allow-other --vfs-cache-mode writes --dir-perms 0755 --file-perms 0644";
        ExecStop = "${pkgs.fuse3}/bin/fusermount3 -u ${mount.mountPoint}";
        Restart = "on-failure";
        RestartSec = "10s";
      };
    };
  }) mounts);
}
