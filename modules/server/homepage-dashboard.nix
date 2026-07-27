{
  config,
  pkgs,
  ...
}: let
  provisionPython = pkgs.python3.withPackages (ps: [ps.uptime-kuma-api]);

  provisionScript = pkgs.writeText "uptime-kuma-provision.py" ''
    import time, sys
    from uptime_kuma_api import UptimeKumaApi

    password_path = sys.argv[1]
    with open(password_path) as f:
        password = f.read().strip()

    api = UptimeKumaApi("http://127.0.0.1:3001")

    for i in range(30):
        try:
            try:
                api.setup("admin", password)
            except Exception:
                api.login("admin", password)
            break
        except Exception as e:
            if i >= 29:
                print(f"Failed to connect to Uptime Kuma: {e}", file=sys.stderr)
                sys.exit(1)
            time.sleep(1)

    monitors = api.get_monitors()
    if not any(m["name"] == "A1 Router" for m in monitors):
        result = api.add_monitor(
            type="ping",
            name="A1 Router",
            hostname="10.0.0.138",
            interval=60,
            retryInterval=60,
            maxretries=3,
        )
        print("Created A1 Router monitor")

    if not any(m["name"] == "Thermomix" for m in monitors):
        result = api.add_monitor(
            type="ping",
            name="Thermomix",
            hostname="thermomix-98f5cd",
            interval=60,
            retryInterval=60,
            maxretries=3,
        )
        print("Created Thermomix monitor")

    if not any(m["name"] == "Raspberry PI" for m in monitors):
        result = api.add_monitor(
            type="ping",
            name="Raspberry PI",
            hostname="rpi",
            interval=60,
            retryInterval=60,
            maxretries=3,
        )
        print("Created Raspberry PI monitor")

    api.disconnect()
  '';
in {
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
      background = {
        image = "https://w.wallhaven.cc/full/je/wallhaven-jexkwm.jpg";
        blur = "sm";
        saturate = 50;
        brightness = 50;
        opacity = 50;
      };
      layout = {
        Systems = {
          style = "row";
          columns = 2;
          Dobby = {
            style = "column";
          };
          "Raspberry Pi" = {
            style = "column";
          };
          Laptop = {
            style = "column";
          };
        };
      };
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
    ];
  };

  services.uptime-kuma = {
    enable = true;
    settings.HOST = "0.0.0.0";
  };

  networking.firewall.allowedTCPPorts = [3001];

  systemd.services.uptime-kuma-provision = {
    description = "Provision Uptime Kuma monitors";
    after = [
      "network.target"
      "uptime-kuma.service"
    ];
    wants = ["uptime-kuma.service"];
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Type = "oneshot";
      Restart = "on-failure";
      RestartSec = 5;
    };
    script = ''
      ${provisionPython}/bin/python ${provisionScript} "${config.sops.secrets.KUMA_PASSWORD.path}"
    '';
  };

  sops.secrets.HOMEPAGE_ENV = {
    owner = "root";
    group = "root";
    mode = "0400";
  };

  sops.secrets.KUMA_PASSWORD = {
    owner = "root";
    group = "root";
    mode = "0400";
  };

  services.prometheus = {
    enable = true;
    port = 9090;
    listenAddress = "127.0.0.1";
    scrapeConfigs = [
      {
        job_name = "harmonia";
        static_configs = [
          {targets = ["127.0.0.1:5000"];}
        ];
      }
    ];
  };
}
