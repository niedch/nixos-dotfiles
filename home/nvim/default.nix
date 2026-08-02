{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.home.nvim;
  nvim = import ./package.nix {inherit pkgs;};
in {
  options.home.nvim = {
    lsp = {
      enable = lib.mkEnableOption "LSP support in Neovim" // {default = true;};
    };
  };

  config = {
    home.packages = with pkgs;
      [
        nvim
        ripgrep
        gcc
        tree-sitter
      ]
      ++ lib.optionals cfg.lsp.enable [
        nodejs
        go
        cargo
        rustc
        python3
      ];

    xdg.configFile."nvim".source = ./nvim-config;

    home.file.".config/nvim-lsp-enabled" = lib.mkIf cfg.lsp.enable {
      text = "";
    };
  };
}
