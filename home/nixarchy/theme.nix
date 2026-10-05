{
  pkgs,
  lib,
  config,
  ...
}:
let
  # One entry per theme, keyed by the theme slug (must match the dir name
  # Omarchy uses, e.g. ~/.local/state/omarchy/current/theme.name).
  #   source     = where the theme itself is fetched from (git).
  #   wallpapers = attrset of filename -> { url; hash; } of extra wallpapers
  #                to download and ADD to the theme's background rotation
  #                (they land in ~/.config/omarchy/backgrounds/<slug>/).
  themes = {
    koyanagi = {
      source = pkgs.fetchFromGitHub {
        owner = "niedch";
        repo = "omarchy-koyanagi-theme";
        rev = "63addbeb6df20cdee9cb007eec8fe81c95e3834f";
        sha256 = "sha256-QP3CGQ8lu4LMocyfrkFa+PYQSpNiqCOZVbcKRV/GVgo=";
      };
      wallpapers = {
      };
    };

    # To add another theme later, add a sibling entry:
    # mytheme = {
    #   source = pkgs.fetchFromGitHub { ... };
    #   wallpapers = { "foo.jpg" = { url = "..."; hash = "..."; }; };
    # };
  };

  # Derive xdg.configFile entries from `themes`:
  #   omarchy/themes/<slug>  -> theme source (recursive)
  themeConfigFiles = lib.mapAttrs'
    (themeName: theme:
      lib.nameValuePair "omarchy/themes/${themeName}" {
        source = theme.source;
        recursive = true;
      })
    themes;

  #   omarchy/backgrounds/<slug>/<file> -> fetched wallpaper
  wallpaperFiles = lib.concatMapAttrs
    (themeName: theme:
      lib.mapAttrs'
        (filename: img:
          lib.nameValuePair "omarchy/backgrounds/${themeName}/${filename}" {
            source = pkgs.fetchurl { inherit (img) url hash; };
          })
        theme.wallpapers)
    themes;
in
{
  xdg.configFile = themeConfigFiles // wallpaperFiles;

  # Re-apply the active theme after every rebuild so Nix-controlled theme
  # changes (e.g. the Ghostty background opacity) reach the staging dir at
  # ~/.local/state/omarchy/current/theme without a manual `omarchy theme refresh`.
  home.activation.omarchyThemeRefresh = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    export PATH="${config.programs.nixarchy.package}/bin:$PATH"
    export OMARCHY_PATH="${config.programs.nixarchy.package}/share/omarchy"
    omarchy theme refresh || true
  '';
}
