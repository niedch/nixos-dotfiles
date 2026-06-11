{ config, pkgs, ... }:

{
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
