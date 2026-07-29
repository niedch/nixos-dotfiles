{ ... }:
{
  disabledModules = [ "services/web-apps/speedtest-tracker.nix" ];

  services.speedtest-tracker = {
    enable = true;
    port = 8080;
    openFirewall = true;
    speedtest.schedule = "0 */2 * * *";
  };
}
