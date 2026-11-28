{config, ...}: {
  flake.modules.homeManager.home-desktop = {rootPath, ...}: {
    imports = with config.flake.modules.homeManager; [
      home-hyprland
      home-dux
      home-browser
      home-ghostty
      home-tmux
      home-tools
      home-nvim
      home-zsh
      home-mise
      home-git
      home-ssh
      home-agents
      home-media
    ];

    programs.home-manager.enable = true;

    home.username = "nic";
    home.homeDirectory = "/home/nic";
    home.stateVersion = "26.05";

    sops.defaultSopsFile = rootPath + "/secrets/secrets.yaml";
    sops.age.keyFile = "/home/nic/.config/sops/age/keys.txt";
  };
}
