{pkgs}:
pkgs.writeShellScriptBin "nvim" ''
  export NVIM_CONFIG=${./nvim-config}
  exec ${pkgs.neovim}/bin/nvim -u "$NVIM_CONFIG/init.lua" "$@"
''
