{
  config,
  pkgs,
  ...
}: {
  sops.secrets.harmonia-secret = {};

  services.harmonia.cache.enable = true;
  services.harmonia.cache.settings = {
    real_nix_store = "/mnt/hdd/nix/store";
    virtual_nix_store = "/mnt/hdd/nix/store";
    sign_key_paths = [
      "/run/harmonia-signing-key"
    ];
  };

  systemd.services.harmonia.serviceConfig.ExecStartPre = [
    "+${pkgs.coreutils}/bin/install -m 400 -o harmonia -g harmonia ${config.sops.secrets.harmonia-secret.path} /run/harmonia-signing-key"
  ];

  networking.firewall.allowedTCPPorts = [5000];
}
