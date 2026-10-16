{config, ...}: {
  sops.secrets.harmonia-secret = {};

  services.harmonia.cache.enable = true;
  services.harmonia.cache.settings.priority = 30;
  services.harmonia.cache.signKeyPaths = [
    config.sops.secrets.harmonia-secret.path
  ];

  networking.firewall.allowedTCPPorts = [5000];
}
