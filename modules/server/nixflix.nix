{ config, ... }: {
  sops.secrets = {
    "sonarr/api_key" = { };
    "sonarr/password" = { };
    "radarr/api_key" = { };
    "radarr/password" = { };
    "prowlarr/api_key" = { };
    "prowlarr/password" = { };
    "jellyfin/api_key" = { };
    "jellyfin/admin_password" = { };
    "wireguard/conf" = { };
    "qbittorrent/password" = { };
    # "sabnzbd/api_key" = { };
    # "sabnzbd/nzb_key" = { };
    # "sabnzbd/username" = { };
    # "sabnzbd/password" = { };
    # "usenet/eweka/username" = { };
    # "usenet/eweka/password" = { };
    # "usenet/newsgroupdirect/username" = { };
    # "usenet/newsgroupdirect/password" = { };
    # "navidrome/password" = { };
  };

  nixflix = {
    enable = true;
    mediaDir = "/mnt/hdd/media";
    stateDir = "/mnt/hdd/nixflix/.state";
    downloadsDir = "/mnt/hdd/downloads";

    # Reverse proxy: choose one
    # nginx.enable = true;
    # caddy.enable = true;

    postgres.enable = false;

    sonarr = {
      enable = true;
      openFirewall = true;
      config = {
        apiKey = {
          _secret = config.sops.secrets."sonarr/api_key".path;
        };
        hostConfig.password = {
          _secret = config.sops.secrets."sonarr/password".path;
        };
      };
    };

    radarr = {
      enable = true;
      openFirewall = true;
      config = {
        apiKey = {
          _secret = config.sops.secrets."radarr/api_key".path;
        };
        hostConfig.password = {
          _secret = config.sops.secrets."radarr/password".path;
        };
      };
    };

    prowlarr = {
      enable = true;
      openFirewall = true;
      config = {
        apiKey = {
          _secret = config.sops.secrets."prowlarr/api_key".path;
        };
        hostConfig.password = {
          _secret = config.sops.secrets."prowlarr/password".path;
        };
        indexers = [
          {
            name = "Knaben";
            priority = 25;
            appProfileId = 1;
          }
          {
            name = "The Pirate Bay";
            priority = 25;
            appProfileId = 1;
          }
          {
            name = "YTS";
            priority = 25;
            appProfileId = 1;
          }
        ];
      };
    };

    # sabnzbd = {
    #   enable = true;
    #   settings = {
    #     misc.api_key = {
    #       _secret = config.sops.secrets."sabnzbd/api_key".path;
    #     };
    #   };
    # };

    torrentClients.qbittorrent = {
      enable = true;
      openFirewall = true;
      webuiPort = 8282;
      password = {
        _secret = config.sops.secrets."qbittorrent/password".path;
      };
      serverConfig = {
        LegalNotice.Accepted = true;
        Preferences = {
          WebUI = {
            Username = "admin";
            Password_PBKDF2 = "@ByteArray(n6kqNbwJWGaznDlgDUUZgA==:RadmCVRW4+7kL8w2SgT7Vn51eUg23x9BualNksC4AMSFp5TI9cZeeo0hbfNuEJZRm2/9I4xzcMyBHgehyNDGcQ==)";
          };
        };
      };
    };

    jellyfin = {
      enable = true;
      openFirewall = true;
      apiKey._secret = config.sops.secrets."jellyfin/api_key".path;
      libraries.Shows.enableRealtimeMonitor = true;
      libraries.Movies.enableRealtimeMonitor = true;
      users.admin = {
        policy.isAdministrator = true;
        password = {
          _secret = config.sops.secrets."jellyfin/admin_password".path;
        };
      };
    };

    vpn = {
      enable = true;
      wgConfFile = config.sops.secrets."wireguard/conf".path;
      accessibleFrom = [
        "10.0.0.0/8"
        "192.168.0.0/16"
      ];
    };

    # navidrome = {
    #   enable = true;
    #   users.admin = {
    #     userName = "admin";
    #     isAdmin = true;
    #     password = {
    #       _secret = config.sops.secrets."navidrome/admin_password".path;
    #     };
    #   };
    # };
  };
}
