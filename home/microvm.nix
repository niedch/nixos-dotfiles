{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./chromium
    ./ghostty
    ./hyprland
    ./quickshell
    ./media
    ./themes
    ./tmux
    ./tools
    ./nvim
    ./zsh
    ./mise
    ./opencode
    ./git
    ./obsidian
  ];

  home.username = "nic";
  home.homeDirectory = "/home/nic";
  home.stateVersion = "26.05";
  programs.home-manager.enable = true;

  sops.secrets = lib.mkForce {};

  home.packages = with pkgs;
    [
      docker-compose
      lazydocker
      localsend
      unzip
      nixfmt
      fd
      jetbrains.idea
      weathr
      signal-desktop
    ]
    ++ [
      libX11
      libxext
      libxrender
      libxi
      libxtst
    ]
    ++ [
      nodejs
      python3
      gnumake
    ];
}
