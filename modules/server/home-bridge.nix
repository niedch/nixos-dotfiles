{
  pkgs,
  config,
  ...
}: let
  homebridgeScripts = pkgs.runCommand "homebridge-scripts" {} ''
    mkdir -p $out
    for f in ${./home-bridge-scripts}/*.sh; do
      [ -f "$f" ] && cp "$f" $out/
    done
    chmod +x $out/*
    true
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
              on = "TRUE";
              state_cmd = "bash /var/lib/homebridge/scripts/usb_toggle.sh";
            }
          ];
        }
      ];
    };
  };

  services.avahi = {
    enable = true;
    nssmdns = true;
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

  security.sudo.extraRules = [
    {
      users = [config.services.homebridge.user];
      commands = [
        {
          command = "${pkgs.coreutils}/bin/tee /sys/bus/usb/drivers/usb/bind";
          options = ["NOPASSWD"];
        }
        {
          command = "${pkgs.coreutils}/bin/tee /sys/bus/usb/drivers/usb/unbind";
          options = ["NOPASSWD"];
        }
      ];
    }
  ];
}
