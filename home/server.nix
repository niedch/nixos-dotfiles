{pkgs, ...}: {
  imports = [
    ./nvim
  ];

  home.username = "nic";
  home.homeDirectory = "/home/nic";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  programs.zsh.initContent = ''
        PROMPT='%F{green}%n@%m%f %F{blue}%~%f
    %F{blue}%(!.#.>)%f '
  '';

  home.packages = with pkgs; [
    git
  ];
}
