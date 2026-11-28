{...}: {
  flake.modules.homeManager.home-tmux = {pkgs, ...}: let
    tmux-sessionizer = pkgs.writeShellScriptBin "tmux-sessionizer.sh" (builtins.readFile ./tmux-sessionizer.sh);
    tmux-popup = pkgs.writeShellScriptBin "tmux-popup.sh" (builtins.readFile ./tmux-popup.sh);
    tmux-opener = pkgs.writeShellScriptBin "tmux-opener.sh" (builtins.readFile ./tmux-opener.sh);
  in {
    xdg.configFile."tmux/tmux.conf".source = ./tmux.conf;

    home.packages = with pkgs; [
      tmux
      tmux-sessionizer
      tmux-popup
      tmux-opener
      yq
      elinks
    ];
  };
}
