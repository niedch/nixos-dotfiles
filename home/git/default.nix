{ pkgs, ... }:

{
  home.packages = with pkgs; [
    git
    github-cli
    (pkgs.writeShellScriptBin "github-auth" ''
      ${lib.getExe pkgs.github-cli} auth login --with-token < /run/secrets/GITHUB_TOKEN
    '')
  ];

  programs.git = {
    enable = true;

    userName = "nic";
    userEmail = "christoph.niederer99@gmail.com";

    extraConfig = {
      push.autoSetupRemote = true;
      pull.rebase = true;
    };
  };
}
