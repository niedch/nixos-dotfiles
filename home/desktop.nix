{pkgs, inputs, ...}:

{
  imports = [
    ./zen-browser
    ./ghostty
    ./hyprland
    ./swaybg
    ./waybar
    ./themes
    ./walker
    ./tmux
    ./mux-session
    ./nvim
    ./zsh
    ./mise
    ./opencode
    ./git
    ./ssh
  ];

  home.username = "nic";
  home.homeDirectory = "/home/nic";
  home.stateVersion = "26.05";

  programs.home-manager.enable = true;

  sops.defaultSopsFile = ../secrets/secrets.yaml;
  sops.age.keyFile = "/home/nic/.config/sops/age/keys.txt";

  home.packages = with pkgs; [
    docker-compose
    nodejs
    (btop.override { cudaSupport = true; })
    bluetui
    wiremix
    spotify
    python3
    gnumake
    inputs."gazelle-tui".packages.${pkgs.system}.default
  ];
}
