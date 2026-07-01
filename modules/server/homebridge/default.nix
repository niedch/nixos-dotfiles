{
  pkgs,
  config,
  ...
}: let
  homebridgeScripts = pkgs.runCommand "homebridge-scripts" {} ''
    mkdir -p $out
    cp ${./usb_toggle.sh} $out/usb_toggle.sh
    chmod +x $out/*
  '';
in {
  services.homebridge = {
    enable = true;
    openFirewall = true;
    settings = {
      bridge = {
        username = "02:3D:E3:CE:30:01";
        pin = "447-29-381";
      };
      platforms = [
        {
          platform = "Cmd4";
          name = "Cmd4";
          accessories = [
            {
              type = "Switch";
              name = "USB-1-1";
              on = "FALSE";
              state_cmd = "bash /var/lib/homebridge/scripts/usb_toggle.sh";
              polling = [
                {
                  characteristic = "on";
                  interval = 60;
                }
              ];
            }
          ];
        }
      ];
    };
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
  };

  systemd.tmpfiles.rules = [
    "L+ /var/lib/homebridge/scripts - - - - ${homebridgeScripts}"
  ];

  systemd.services.homebridge.preStart = ''
    if [ ! -d "${config.services.homebridge.pluginPath}/homebridge-cmd4" ]; then
      sudo -u homebridge ${pkgs.nodejs}/bin/npm --prefix ${builtins.dirOf config.services.homebridge.pluginPath} install --no-save --ignore-scripts homebridge-cmd4 || true
    fi
  '';

  systemd.services.homebridge.serviceConfig.TimeoutStartSec = 600;

  systemd.services.usb-default-off = {
    description = "Unbind USB device 1-1 at boot (default off)";
    after = ["sysinit.target"];
    before = ["homebridge.service"];
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      if [ -L /sys/bus/usb/drivers/usb/1-1 ]; then
        echo '1-1' > /sys/bus/usb/drivers/usb/unbind
      fi
    '';
  };

  users.groups.usb-toggler = {};

  users.users.${config.services.homebridge.user}.extraGroups = ["usb-toggler"];

  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ACTION=="add", RUN+="${pkgs.coreutils}/bin/chmod 0660 /sys/bus/usb/drivers/usb/bind /sys/bus/usb/drivers/usb/unbind"
    SUBSYSTEM=="usb", ACTION=="add", RUN+="${pkgs.coreutils}/bin/chgrp usb-toggler /sys/bus/usb/drivers/usb/bind /sys/bus/usb/drivers/usb/unbind"
  '';
}
