{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./chromium
    ./ghostty
    ./hyprland
    ./media
    ./themes
    ./tmux
    ./tools
    ./nvim
    ./zsh
    ./mise
    ./opencode
    ./git
    ./ssh
    ./obsidian
    ./quickshell
  ];

  home.username = "nic";
  home.homeDirectory = "/home/nic";
  home.stateVersion = "26.05";
  programs.home-manager.enable = true;

  sops.defaultSopsFile = ../secrets/secrets.yaml;
  sops.age.keyFile = "/home/nic/.config/sops/age/keys.txt";

  home.packages = with pkgs;
    [
      docker-compose
      lazydocker
      unzip
      nixfmt
      fd
      jetbrains.idea
      weathr
      signal-desktop
    ]
    ++ [
      # AWT dependency for the eddi project
      libX11
      libxext
      libxrender
      libxi
      libxtst
    ]
    ++ [
      # Programming languages
      nodejs
      python3
      gnumake
    ];
}
