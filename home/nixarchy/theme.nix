{
  pkgs,
  lib,
  config,
  ...
}:
{
  xdg.configFile."omarchy/themes/koyanagi" = {
    source = pkgs.fetchFromGitHub {
      owner = "niedch";
      repo = "omarchy-koyanagi-theme";
      rev = "63addbeb6df20cdee9cb007eec8fe81c95e3834f";
      sha256 = "sha256-QP3CGQ8lu4LMocyfrkFa+PYQSpNiqCOZVbcKRV/GVgo=";
    };
    recursive = true;
  };

  # Re-apply the active theme after every rebuild so Nix-controlled theme
  # changes (e.g. the Ghostty background opacity) reach the staging dir at
  # ~/.local/state/omarchy/current/theme without a manual `omarchy theme refresh`.
  home.activation.omarchyThemeRefresh = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    export PATH="${config.programs.nixarchy.package}/bin:$PATH"
    export OMARCHY_PATH="${config.programs.nixarchy.package}/share/omarchy"
    omarchy theme refresh || true
  '';
}
