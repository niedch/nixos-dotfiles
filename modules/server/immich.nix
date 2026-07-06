{pkgs, ...}: {
  services.immich = {
    enable = true;
    host = "0.0.0.0";
    openFirewall = true;
    mediaLocation = "/var/lib/immich";
  };
  services.redis.servers.immich.logLevel = "warning";
}
