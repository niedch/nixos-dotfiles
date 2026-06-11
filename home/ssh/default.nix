{ config, pkgs, ... }:

{
  sops.secrets = {
    "git_ed25519" = {
      path = "${config.home.homeDirectory}/.ssh/git_ed25519";
      mode = "0600";
    };
    "git_ed25519_pub" = {
      path = "${config.home.homeDirectory}/.ssh/git_ed25519.pub";
      mode = "0644";
    };
  };

  programs.ssh = {
    enable = true;

    matchBlocks = {
      "github.com" = {
        hostname = "github.com";
        user = "nic";
        identityFile = "~/.ssh/git_ed25519";
        identitiesOnly = true;
      };
    };
  };
}
