{config, ...}: {
  services.github-runners."nix-harmonia-runner" = {
    enable = true;
    url = "https://github.com/niedch/nixos-dotfiles";
    tokenFile = config.sops.secrets.GITHUB_RUNNER_TOKEN.path;
    name = "nix-harmonia-runner";
    extraLabels = ["nix" "self-hosted" "harmonia"];
    user = "runner";
    group = "runner";
    replace = true;
    serviceOverrides = {
      ReadWritePaths = ["/mnt/hdd/nix"];
      Environment = ["TMPDIR=/run/github-runner/nix-harmonia-runner"];
    };
  };

  systemd.services.github-runner-nix-harmonia-runner = {
    after = ["mnt-hdd.mount"];
    requires = ["mnt-hdd.mount"];
  };

  sops.secrets.GITHUB_RUNNER_TOKEN = {};

  nix.settings = {
    substituters = [
      "http://127.0.0.1:5000"
      "https://cache.nixos.org"
    ];
    trusted-users = [
      "root"
      "runner"
    ];
  };

  users.users.runner = {
    isSystemUser = true;
    group = "runner";
    extraGroups = ["nixbld"];
    home = "/var/lib/github-runner";
    createHome = true;
  };
  users.groups.runner = {};
}
