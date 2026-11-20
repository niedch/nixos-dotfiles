{ ... }: {
  imports = [
    ./nvim
    ./zsh
    ./git
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
}
