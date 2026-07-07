{
  pkgs,
  inputs,
  lib,
  ...
}: {
  imports = [
    inputs.omanix.homeManagerModules.default
    ./chromium
    ./kdenlive
    ./music
    ./quickshell
  ];

  # Disable programs.chromium binary — omanix's firefox handles the browser;
  # the chromium module only provides web app desktop entries.
  programs.chromium.enable = lib.mkForce false;

  omanix = {
    user = {
      name = "nic";
      email = "christoph.niederer99@gmail.com";
    };

    terminal.emulator = "ghostty";
    languages = {
      nix.enable = true;
      go.enable = true;
      rust.enable = true;
      java.enable = true;
      markdown.enable = true;
      json.enable = true;
      docker.enable = true;
    };
    apps = {
      neovim.enable = true;
      tmux.enable = false; # using own home/tmux
      obsidian.enable = true;
      spotify.enable = false; # using own home/music
      gh.enable = false; # using own home/git
    };
  };
}
