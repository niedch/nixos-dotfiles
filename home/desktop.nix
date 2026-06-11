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
  ];

  home.username = "nic";
  home.homeDirectory = "/home/nic";
  home.stateVersion = "26.05";

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    docker-compose
    nodejs
    btop
    bluetui
    wiremix
    spotify
    python3
    gnumake
    inputs."gazelle-tui".packages.${pkgs.system}.default
  ];
}
