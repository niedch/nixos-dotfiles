{
  pkgs,
  lib,
  inputs,
  ...
}:

{
  imports = [
    ./brave
    ./ghostty
    ./hyprland
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
    lazydocker
    nodejs
    localsend
    nixfmt
    (btop.override { cudaSupport = true; })
    bluetui
    wiremix
    spotify
    python3
    gnumake
    obsidian
    inputs.wlctl.packages.${pkgs.stdenv.hostPlatform.system}.default
    fd
    unzip
    jetbrains.idea
  ];

  xdg.configFile."comd/config.toml".text = ''
    [global]
    system_prompt = """
    You are a helper Bot for Bash! Only responded with a single line of bash. Only bash! No Backticks!
    """
    model = "gemini-2.5-flash"
  '';
}
