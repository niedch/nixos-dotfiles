{ config, pkgs, ... }:

{
    home.packages = with pkgs; [
        neovim
        nodejs
        go
        cargo
        rustc
        gcc
    ];

    xdg.configFile."nvim".source = ./nvim-config;
}
