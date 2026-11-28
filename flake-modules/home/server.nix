{config, ...}: {
  flake.modules.homeManager.home-server = {...}: {
    imports = with config.flake.modules.homeManager; [
      home-nvim
      home-zsh
      home-git
      home-tmux
    ];

    programs.home-manager.enable = true;

    home.username = "nic";
    home.homeDirectory = "/home/nic";
    home.stateVersion = "25.11";

    home.nvim.lsp.enable = false;

    programs.zsh.initContent = ''
          PROMPT='%F{green}%n@%m%f %F{blue}%~%f
      %F{blue}%(!.#.>)%f '
    '';
  };
}
