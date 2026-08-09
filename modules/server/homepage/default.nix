{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./prometheus.nix
    ./kuma.nix
    ./speedtest-tracker.nix
    ./message-board.nix
  ];

  sops.secrets.HOMEPAGE_ENV = {
    owner = "root";
    group = "root";
    mode = "0400";
  };

  services.homepage-dashboard = {
    enable = true;
    openFirewall = true;
    listenPort = 8082;
    allowedHosts = "dobby:8082,localhost:8082,127.0.0.1:8082";

    environmentFiles = [
      config.sops.secrets.HOMEPAGE_ENV.path
    ];

    settings = {};

    widgets = [
      {
        resources = {
          cpu = true;
          memory = true;
          disk = [
            "/"
            "/mnt/hdd"
          ];
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
              icon = "samba-server.png";
              href = "//dobby/share";
              description = "Network File Share";
            };
          }
          {
            "Nix Cache" = {
              icon = "nixos.png";
              href = "http://dobby:5000";
              description = "Harmonia Binary Cache";
              widget = {
                type = "prometheusmetric";
                url = "http://127.0.0.1:9090";
                metrics = [
                  {
                    label = "Narinfo Hits";
                    query = "harmonia_http_requests_total{path='/{hash}.narinfo',status='200'}";
                  }
                  {
                    label = "Narinfo Misses";
                    query = "harmonia_http_requests_total{path='/{hash}.narinfo',status='404'}";
                  }
                  {
                    label = "Nar Downloads";
                    query = "harmonia_http_requests_total{path=~'/nar/.*',status='200'}";
                  }
                  {
                    label = "Nar 404s";
                    query = "harmonia_http_requests_total{path=~'/nar/.*',status='404'}";
                  }
                ];
              };
            };
          }
          {
            "GitHub Runner" = {
              icon = "github.png";
              href = "https://github.com/niedch/nixos-dotfiles/actions";
              description = "Self-hosted Actions Runner";
            };
          }
          {
            "Uptime Kuma" = {
              icon = "uptime-kuma.png";
              href = "http://dobby:3001";
              description = "Uptime Kuma Instance";
            };
          }
        ];
      }
      {
        "Network" = [
          {
            "A1 Router" = {
              icon = "router.png";
              href = "http://10.0.0.138";
              description = "A1 WLAN Box (DX3101-B0)";
              widget = {
                type = "uptimekuma";
                url = "http://127.0.0.1:3001";
                slug = "router";
              };
            };
          }
          {
            "Raspberry PI" = {
              icon = "raspberry-pi.png";
              description = "Raspberry PI";
              widget = {
                type = "uptimekuma";
                url = "http://127.0.0.1:3001";
                slug = "rpi";
              };
            };
          }
          {
            "Speedtest Tracker" = {
              icon = "speedtest-tracker.png";
              href = "http://dobby:8080/dashboard/";
              description = "Internet Speed Monitoring";
              widget = {
                type = "speedtest";
                url = "http://dobby:8080";
                version = 2;
              };
            };
          }
        ];
      }
      {
        "Dobby" = [
          {
            Dobby = {
              icon = "glances.png";
              href = "http://dobby:61208";
              widget = {
                type = "glances";
                url = "http://127.0.0.1:61208";
                metric = "info";
                version = 4;
              };
            };
          }
          {
            Storage = [
              {
                "Dobby Storage" = {
                  icon = "glances.png";
                  href = "http://dobby:61208";
                  widget = {
                    type = "glances";
                    url = "http://127.0.0.1:61208";
                    metric = "fs:/";
                    version = 4;
                  };
                };
              }
              {
                "Dobby HDD" = {
                  icon = "glances.png";
                  href = "http://dobby:61208";
                  widget = {
                    type = "glances";
                    url = "http://127.0.0.1:61208";
                    metric = "fs:/mnt/hdd";
                    version = 4;
                  };
                };
              }
            ];
          }
        ];
      }
      {
        "Raspberry Pi" = [
          {
            "Raspberry Pi" = {
              icon = "glances.png";
              href = "http://rpi:61208";
              widget = {
                type = "glances";
                url = "http://rpi:61208";
                metric = "info";
                version = 4;
              };
            };
          }
          {
            "RPi Storage" = {
              icon = "glances.png";
              href = "http://rpi:61208";
              widget = {
                type = "glances";
                url = "http://rpi:61208";
                metric = "fs:/";
                version = 4;
              };
            };
          }
        ];
      }
      {
        "Laptop" = [
          {
            "Laptop" = {
              icon = "glances.png";
              href = "http://nixos:61208";
              widget = {
                type = "glances";
                url = "http://nixos:61208";
                metric = "info";
                version = 4;
              };
            };
          }
          {
            "Laptop Storage" = {
              icon = "glances.png";
              href = "http://nixos:61208";
              widget = {
                type = "glances";
                url = "http://nixos:61208";
                metric = "fs:/";
                version = 4;
              };
            };
          }
        ];
      }
      {
        "Messages" = [
          {
            "Messages" = {
              icon = "mdi-clipboard-text";
              href = "http://dobby:8090";
              description = "Server Messages";
              widget = {
                type = "customapi";
                url = "http://dobby:8090";
                display = "dynamic-list";
                mappings = {
                  name = "name";
                  label = "label";
                };
              };
            };
          }
        ];
      }
    ];
  };

  environment.etc."homepage-dashboard/settings.yaml".source = lib.mkForce ./layout-config.yaml;
}
