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
