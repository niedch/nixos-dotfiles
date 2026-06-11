{ pkgs, ... }:

{
  home.packages = with pkgs; [
    git
  ];

  programs.git = {
    enable = true;

    userName = "nic";
    userEmail = "christoph.niederer99@gmail.com";
  };
}
