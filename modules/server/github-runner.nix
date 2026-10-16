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
      ReadWritePaths = ["/nix/var/nix/profiles/per-user/runner"];
      Environment = ["TMPDIR=/run/github-runner/nix-harmonia-runner"];
    };
  };

  systemd.tmpfiles.rules = [
    "d /nix/var/nix/profiles/per-user/runner 0755 runner runner -"
  ];

  sops.secrets.GITHUB_RUNNER_TOKEN = {};

  users.users.runner = {
    isSystemUser = true;
    group = "runner";
    extraGroups = ["nixbld"];
    home = "/var/lib/github-runner";
    createHome = true;
  };
  users.groups.runner = {};
}
