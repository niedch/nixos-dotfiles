{
  config,
  pkgs,
  lib,
  ...
}:
lib.mkIf config.sops.enable {
  environment.systemPackages = [pkgs.cifs-utils];

  sops.secrets.SAMBA_PASSWORD = {
    owner = "root";
    group = "root";
    mode = "0400";
  };

  systemd.services.samba-credentials = {
    description = "Create Samba credentials file";
    wantedBy = ["multi-user.target"];
    unitConfig.ConditionPathExists = config.sops.secrets.SAMBA_PASSWORD.path;
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = "yes";
    };
    script = ''
      install -m 600 /dev/null /run/samba-credentials
      printf 'username=nic\npassword=%s\n' \
        "$(cat ${config.sops.secrets.SAMBA_PASSWORD.path})" > /run/samba-credentials
    '';
  };

  fileSystems."/media/Dobby-Share" = {
    device = "//dobby/share";
    fsType = "cifs";
    options = [
      "credentials=/run/samba-credentials"
      "uid=1000"
      "gid=100"
      "forceuid"
      "forcegid"
      "file_mode=0644"
      "dir_mode=0755"
      "x-systemd.requires=samba-credentials.service"
      "x-systemd.after=samba-credentials.service"
      "x-systemd.requires=network-online.target"
      "x-systemd.after=network-online.target"
      "x-systemd.device-timeout=15s"
      "x-systemd.mount-timeout=30s"
      "_netdev"
    ];
  };
}
