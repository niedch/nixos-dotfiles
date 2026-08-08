{config, ...}: {
  sops.secrets.harmonia-secret = {};

  systemd.services.harmonia = {
    after = ["mnt-hdd.mount"];
    requires = ["mnt-hdd.mount"];
  };

  services.harmonia.cache.enable = true;
  services.harmonia.cache.settings.real_nix_store = "/mnt/hdd/nix/store";
  services.harmonia.cache.signKeyPaths = [
    config.sops.secrets.harmonia-secret.path
  ];

  networking.firewall.allowedTCPPorts = [5000];
}
