{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    neovim
    nodejs
    go
    ripgrep
    cargo
    rustc
    gcc
    tree-sitter
  ];

  xdg.configFile."nvim".source = ./nvim-config;
}
