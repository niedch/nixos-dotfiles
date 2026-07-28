{ ... }:
{
  disabledModules = [ "services/web-apps/speedtest-tracker.nix" ];

  services.speedtest-tracker = {
    enable = true;
    port = 8080;
    speedtest.schedule = "0 * * * *";
  };
}
