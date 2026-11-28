# Syncthing — file sync between dobby (server), laptop, desktop, and iphone.
#
# Kept as a standalone feature (NOT part of the `common` bundle) so it can be
# included selectively per host.
{...}: {
  flake.modules.nixos.common-syncthing = {config, ...}: let
    devices = {
      dobby.id = "YKTFECV-IXRAGEA-RUZJOPB-GPHZQ5O-NLY7LX3-OLL5TFL-JZGHP4B-XVCSNQD";
      laptop.id = "HGIVVTS-CIYDDOY-VLBG544-Y4Q4TH6-JCIJEKM-LUGJ7CV-SK7DNZL-AQCLFAB";
      iphone.id = "FLZ43AZ-7JF3KFZ-P7ACF4P-2NA2C5E-S2G2VJF-7DQ2P7Y-6CWFCAC-AHR5CAP";
      desktop.id = "C73UHHZ-VJKVUN2-E5C5NVU-BY62OAL-LKCXJDG-K2LI3HR-7WYBE57-WXE5QQC";
    };
    folders."obsidian-vault" = {
      id = "obsidian-vault";
      label = "Obsidian Vault";
      path = "/home/nic/Projects/obsidian-vault";
      type = "sendreceive";
      devices = ["dobby" "laptop" "iphone" "desktop"];
    };
    folders."downloads" = {
      id = "downloads";
      label = "Downloads";
      path = "/home/nic/Downloads";
      type = "sendreceive";
      devices = ["dobby" "laptop" "desktop"];
    };
    folders."images" = {
      id = "images";
      label = "Images";
      path = "/home/nic/Pictures";
      type = "sendreceive";
      devices = ["dobby" "laptop" "desktop"];
    };
    folders."videos" = {
      id = "videos";
      label = "Videos";
      path = "/home/nic/Videos";
      type = "sendreceive";
      devices = ["dobby" "laptop" "desktop"];
    };
    folders."documents" = {
      id = "documents";
      label = "Documents";
      path = "/home/nic/Documents";
      type = "sendreceive";
      devices = ["dobby" "laptop" "desktop"];
    };
  in {
    services.syncthing = {
      enable = true;
      user = "nic";
      group = "users";
      dataDir = "/home/nic/.local/share/syncthing";
      configDir = "/home/nic/.config/syncthing";
      openDefaultPorts = true;
      guiPasswordFile = config.sops.secrets.SYNCTHING_GUI_PASSWORD.path;
      settings = {
        inherit devices folders;
      };
      extraFlags = ["--gui-apikey=$(cat ${config.sops.secrets.SYNCTHING_API_KEY.path})"];
    };

    systemd.tmpfiles.rules = [
      "d /home/nic/Projects 0755 nic users - -"
    ];

    sops.secrets.SYNCTHING_GUI_PASSWORD = {
      owner = "nic";
      group = "users";
      mode = "0440";
    };

    sops.secrets.SYNCTHING_API_KEY = {
      owner = "nic";
      group = "users";
      mode = "0440";
    };
  };
}
