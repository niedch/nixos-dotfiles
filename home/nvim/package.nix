{pkgs}:
pkgs.writeShellScriptBin "nvim" ''
  export NVIM_CONFIG=${./nvim-config}
  exec ${pkgs.neovim}/bin/nvim --cmd "set rtp^=$NVIM_CONFIG" -u "$NVIM_CONFIG/init.lua" "$@"
''
