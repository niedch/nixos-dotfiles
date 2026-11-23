{
  ...
}:
{
  imports = [
    ./hyprland
    # ./noctalia
    ./dux
    ./browser
    ./ghostty
    ./tmux
    ./tools
    ./nvim
    ./zsh
    ./mise
    ./git
    ./ssh
    ./agents
    ./media
  ];

  programs.home-manager.enable = true;

  home.username = "nic";
  home.homeDirectory = "/home/nic";
  home.stateVersion = "26.05";

  sops.defaultSopsFile = ../secrets/secrets.yaml;
  sops.age.keyFile = "/home/nic/.config/sops/age/keys.txt";
}
