{
  config,
  pkgs,
  ...
}: let
  shareName = "share";
  sharePath = "/mnt/hdd/samba";
in {
  systemd.tmpfiles.rules = [
    "d ${sharePath} 0755 nic users - -"
  ];

  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        "workgroup" = "WORKGROUP";
        "server string" = "dobby";
        "netbios name" = "dobby";
        "security" = "user";
        "map to guest" = "bad user";
      };
      "${shareName}" = {
        "path" = sharePath;
        "read only" = "no";
        "browsable" = "yes";
        "guest ok" = "no";
        "valid users" = "nic";
        "force user" = "nic";
        "create mask" = "0644";
        "directory mask" = "0755";
      };
    };
  };

  sops.secrets.SAMBA_PASSWORD = {
    owner = "root";
    group = "root";
    mode = "0400";
  };

  systemd.services.samba-setup = {
    description = "Set Samba password for nic";
    before = ["samba-smbd.service"];
    unitConfig.ConditionPathExists = config.sops.secrets.SAMBA_PASSWORD.path;
    wantedBy = ["samba-smbd.service"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = "yes";
    };
    path = [pkgs.samba];
    script = ''
      if ! pdbedit -L 2>/dev/null | grep -q "^nic:"; then
        printf '%s\n%s\n' "$(cat ${config.sops.secrets.SAMBA_PASSWORD.path})" \
          "$(cat ${config.sops.secrets.SAMBA_PASSWORD.path})" | smbpasswd -s -a nic
      fi
    '';
  };
}
