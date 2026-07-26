{
  config,
  pkgs,
  ...
}: let
  uptimeKumaApi = pkgs.python3Packages.buildPythonPackage rec {
    pname = "uptime-kuma-api";
    version = "1.2.1";
    format = "setuptools";
    src = pkgs.fetchurl {
      url = "https://files.pythonhosted.org/packages/40/01/da3e682364231077b05417ffa32e11ef84deee2b6f4dd6ee740cf097df28/uptime_kuma_api-1.2.1.tar.gz";
      hash = "sha256-tZ5ln3sy6W5RLcwjzLbhobCNLbHXIhXIzrcOVCG+Z+E=";
    };
    propagatedBuildInputs = with pkgs.python3Packages; [
      python-socketio
      requests
      packaging
      websocket-client
    ];
    doCheck = false;
    postPatch = ''
      substituteInPlace uptime_kuma_api/api.py \
        --replace-fail 'resendInterval: int = 0,' 'resendInterval: int = 0, conditions: str = "",' \
        --replace-fail '"resendInterval": resendInterval,' '"resendInterval": resendInterval, "conditions": conditions,'
    '';
  };

  provisionPython = pkgs.python3.withPackages (
    pythonPackages:
      with pythonPackages; [
        uptimeKumaApi
      ]
  );

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

    # Get the monitor ID
    monitor_id = None
    for m in api.get_monitors():
        if m["name"] == "A1 Router":
            monitor_id = m["id"]
            break

    # Create a status page if needed
    status_pages = api.get_status_pages()
    if not any(sp["slug"] == "router" for sp in status_pages):
        api._call("addStatusPage", ("Network", "router"))
        print("Created status page 'router'")
        status_pages = api.get_status_pages()

    # Find the status page ID
    page_id = None
    for sp in status_pages:
        if sp["slug"] == "router":
            page_id = sp["id"]
            break

    print(f"status_page_id={page_id} monitor_id={monitor_id}")

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
            Backrest = {
              icon = "backrest.png";
              href = "http://dobby:9898";
              description = "Restic Backup Web UI";
              widget = {
                type = "backrest";
                url = "http://127.0.0.1:9898";
              };
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
            "Thermomix" = {
              description = "Thermomix";
              widget = {
                type = "uptimekuma";
                url = "http://127.0.0.1:3001";
                slug = "thermo";
              };
            };
          }
        ];
      }
      {
        "Systems" = [
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
}
