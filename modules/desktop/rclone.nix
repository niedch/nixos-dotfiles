{config, pkgs, ...}: let
  remote = "G-Drive:Documents";
  mountPoint = "/media/gdrive";
in {
  environment.systemPackages = [pkgs.rclone];

  systemd.services.rclone-mount = {
    description = "rclone mount service (G-Drive)";
    after = ["network-online.target"];
    wants = ["network-online.target"];
    wantedBy = ["multi-user.target"];

    serviceConfig = {
      Type = "simple";
      ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p ${mountPoint}";
      ExecStart = "${pkgs.rclone}/bin/rclone mount ${remote} ${mountPoint} --config ${config.sops.secrets.rclone-config.path} --allow-other --vfs-cache-mode writes --dir-perms 0755 --file-perms 0644";
      ExecStop = "${pkgs.fuse3}/bin/fusermount3 -u ${mountPoint}";
      Restart = "on-failure";
      RestartSec = "10s";
    };
  };
}
