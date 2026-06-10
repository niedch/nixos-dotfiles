{ inputs, pkgs, ... }:

let
  omarchyRepo = "https://github.com/basecamp/omarchy.git";
  omarchyRef = "dev";
  omarchyHash = "sha256-ipvHygN3eiSSyQszUwf00khNg/Tf/BEDlZmiRWUhXRc=";
in
{
  imports = [ inputs.nix-omarchy-theme.homeManagerModules.default ];

  omarchy-themes = {
    enable = true;
    defaultTheme = "kanso";

    themes = {
      catppuccin-latte = { url = omarchyRepo; ref = omarchyRef; hash = omarchyHash; subpath = "themes/catppuccin-latte"; };
      catppuccin = { url = omarchyRepo; ref = omarchyRef; hash = omarchyHash; subpath = "themes/catppuccin"; };
      ethereal = { url = omarchyRepo; ref = omarchyRef; hash = omarchyHash; subpath = "themes/ethereal"; };
      everforest = { url = omarchyRepo; ref = omarchyRef; hash = omarchyHash; subpath = "themes/everforest"; };
      flexoki-light = { url = omarchyRepo; ref = omarchyRef; hash = omarchyHash; subpath = "themes/flexoki-light"; };
      gruvbox = { url = omarchyRepo; ref = omarchyRef; hash = omarchyHash; subpath = "themes/gruvbox"; };
      hackerman = { url = omarchyRepo; ref = omarchyRef; hash = omarchyHash; subpath = "themes/hackerman"; };
      kanagawa = { url = omarchyRepo; ref = omarchyRef; hash = omarchyHash; subpath = "themes/kanagawa"; };
      kanso = { url = "https://github.com/HANCORE-linux/omarchy-kanso-theme.git"; ref = "main"; hash = "sha256-AfwCqhF7WMtavS+Z1YTO1YU3XsfGiwDyGhjhzYyvsfY="; };
      last-horizon = { url = omarchyRepo; ref = omarchyRef; hash = omarchyHash; subpath = "themes/last-horizon"; };
      lumon = { url = omarchyRepo; ref = omarchyRef; hash = omarchyHash; subpath = "themes/lumon"; };
      matte-black = { url = omarchyRepo; ref = omarchyRef; hash = omarchyHash; subpath = "themes/matte-black"; };
      miasma = { url = omarchyRepo; ref = omarchyRef; hash = omarchyHash; subpath = "themes/miasma"; };
      nord = { url = omarchyRepo; ref = omarchyRef; hash = omarchyHash; subpath = "themes/nord"; };
      osaka-jade = { url = omarchyRepo; ref = omarchyRef; hash = omarchyHash; subpath = "themes/osaka-jade"; };
      retro-82 = { url = omarchyRepo; ref = omarchyRef; hash = omarchyHash; subpath = "themes/retro-82"; };
      ristretto = { url = omarchyRepo; ref = omarchyRef; hash = omarchyHash; subpath = "themes/ristretto"; };
      rose-pine = { url = omarchyRepo; ref = omarchyRef; hash = omarchyHash; subpath = "themes/rose-pine"; };
      solitude = { url = omarchyRepo; ref = omarchyRef; hash = omarchyHash; subpath = "themes/solitude"; };
      tokyo-night = { url = omarchyRepo; ref = omarchyRef; hash = omarchyHash; subpath = "themes/tokyo-night"; };
      vantablack = { url = omarchyRepo; ref = omarchyRef; hash = omarchyHash; subpath = "themes/vantablack"; };
      white = { url = omarchyRepo; ref = omarchyRef; hash = omarchyHash; subpath = "themes/white"; };
    };

    selectorCommand = "walker --dmenu";

    gtk = {
      cursorTheme = {
        name = "Bibata-Modern-Classic";
        package = pkgs.bibata-cursors;
        size = 12;
      };
    };

    symlinks = {
      "hypr/theme.lua".source = "hyprland.lua";
      "waybar/colors.css".source = "waybar.css";
      "walker/themes/kanso/style.css".source = "walker.css";
    };
  };
}
