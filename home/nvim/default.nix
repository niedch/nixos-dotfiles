{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.home.nvim;
in {
  options.home.nvim = {
    lsp = {
      enable = lib.mkEnableOption "LSP support in Neovim" // {default = true;};
    };
  };

  config = {
    home.packages = with pkgs;
      [
        neovim
        ripgrep
        gcc
        tree-sitter
      ]
      ++ lib.optionals cfg.lsp.enable [
        nodejs
        go
        cargo
        rustc
      ];

    xdg.configFile."nvim".source = ./nvim-config;

    home.file.".config/nvim-lsp-enabled" = lib.mkIf cfg.lsp.enable {
      text = "";
    };
  };
}
