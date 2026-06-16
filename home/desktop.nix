{
  pkgs,
  inputs,
  ...
}: {
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

  programs.btop = {
    enable = true;
    package = pkgs.btop.override { cudaSupport = true; };
    settings = {
      color_theme = "btop";
    };
  };

  sops.defaultSopsFile = ../secrets/secrets.yaml;
  sops.age.keyFile = "/home/nic/.config/sops/age/keys.txt";

  home.packages = with pkgs; [
    yaru-theme
    docker-compose
    lazydocker
    nodejs
    localsend
    nixfmt
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
