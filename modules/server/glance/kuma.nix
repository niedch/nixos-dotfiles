{
  config,
  pkgs,
  ...
}: let
  provisionPython = pkgs.python3.withPackages (ps: [
    ps.uptime-kuma-api
    ps.packaging
    ps.requests
  ]);

  provisionScript = pkgs.writeText "uptime-kuma-provision.py" ''
    import requests, sys, time
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

    # Ensure default status page exists
    status_pages = api.get_status_pages()
    if not any(sp["slug"] == "default" for sp in status_pages):
        api.add_status_page("default", "default")
        print("Created default status page")

    monitors = api.get_monitors()
    all_monitor_ids = {m["id"] for m in monitors}

    # Fetch publicGroupList safely via HTTP REST endpoint.
    # Note: api.get_status_page() and api.save_status_page() from uptime-kuma-api 1.2.x
    # are incompatible with Uptime Kuma 2.x (which returns 'incidents' instead of 'incident',
    # and has extra config fields that break _build_status_page_data).
    current_monitor_ids = set()
    try:
        resp = requests.get("http://127.0.0.1:3001/api/status-page/default", timeout=10)
        if resp.status_code == 200:
            current_groups = resp.json().get("publicGroupList", [])
            current_monitor_ids = {
                m["id"]
                for group in current_groups
                for m in group.get("monitorList", [])
            }
    except Exception as e:
        print(f"Warning: could not fetch status page publicGroupList: {e}")

    if current_monitor_ids != all_monitor_ids:
        page_config = api._call("getStatusPage", "default")["config"]
        icon = page_config.get("icon") or "/icon.svg"
        new_public_group_list = [
            {
                "name": "Services",
                "weight": 1,
                "monitorList": [{"id": m["id"]} for m in sorted(monitors, key=lambda m: m["name"])],
            }
        ]
        api._call("saveStatusPage", ("default", page_config, icon, new_public_group_list))
        print("Updated default status page publicGroupList")

    api.disconnect()
  '';
in {
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

  sops.secrets.KUMA_PASSWORD = {
    owner = "root";
    group = "root";
    mode = "0400";
  };
}
