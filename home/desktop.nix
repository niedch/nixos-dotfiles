{
  ...
}:
{
  imports = [
    ./hyprland
    ./noctalia
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

  home.username = "nic";
  home.homeDirectory = "/home/nic";
  home.stateVersion = "26.05";
  programs.home-manager.enable = true;

  sops.defaultSopsFile = ../secrets/secrets.yaml;
  sops.age.keyFile = "/home/nic/.config/sops/age/keys.txt";
}
