{
  config,
  ...
}: {
  services.homepage-dashboard = {
    enable = true;
    openFirewall = true;
    listenPort = 8082;
    allowedHosts = "dobby:8082,localhost:8082,127.0.0.1:8082";

    environmentFiles = [
      config.sops.secrets.HOMEPAGE_ENV.path
    ];

    settings = {
      title = "Dobby Dashboard";
      theme = "dark";
      headerStyle = "boxed";
      statusStyle = "dot";
      target = "_blank";
    };

    widgets = [
      {
        resources = {
          cpu = true;
          memory = true;
          disk = "/";
        };
      }
      {
        search = {
          provider = "duckduckgo";
          target = "_blank";
        };
      }
      {
        datetime = {
          format = {
            timeStyle = "short";
            dateStyle = "short";
          };
        };
      }
    ];

    services = [
      {
        "Media" = [
          {
            Immich = {
              icon = "immich.png";
              href = "http://dobby:2283";
              description = "Photo & Video Management";
              widget = {
                type = "immich";
                url = "http://dobby:2283";
                key = "{{HOMEPAGE_VAR_IMMICH_KEY}}";
                version = 2;
              };
            };
          }
        ];
      }
      {
        "Smart Home" = [
          {
            Homebridge = {
              icon = "homebridge.png";
              href = "http://rpi:8581";
              description = "HomeKit Bridge";
              widget = {
                type = "homebridge";
                url = "http://rpi:8581";
                username = "{{HOMEPAGE_VAR_HOMEBRIDGE_USERNAME}}";
                password = "{{HOMEPAGE_VAR_HOMEBRIDGE_PASSWORD}}";
              };
            };
          }
        ];
      }
      {
        "Infrastructure" = [
          {
            "Samba Share" = {
              icon = "samba.png";
              href = "smb://dobby/share";
              description = "Network File Share";
            };
          }
          {
            "Nix Cache" = {
              icon = "nixos.png";
              href = "http://dobby:5000";
              description = "Harmonia Binary Cache";
            };
          }
          {
            "GitHub Runner" = {
              icon = "github.png";
              href = "https://github.com/niedch/nixos-dotfiles/actions";
              description = "Self-hosted Actions Runner";
            };
          }
        ];
      }
    ];
  };

  sops.secrets.HOMEPAGE_ENV = {
    owner = "root";
    group = "root";
    mode = "0400";
  };
}
