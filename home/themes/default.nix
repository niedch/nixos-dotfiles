{ inputs, pkgs, ... }:

let
  omarchyRepo = "https://github.com/basecamp/omarchy.git";
  omarchyRef = "9cf1852525a5f7de26d3162db9d61e2f5c1d5523";
  omarchyHash = "sha256-9zkIEgD/L5+eK5fuQNXbBd5XXO+NwH6QWGiDI//kGas=";
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
      gruvbox = { url = omarchyRepo; ref = omarchyRef; hash = omarchyHash; subpath = "themes/gruvbox"; };
      kanso = { url = "https://github.com/HANCORE-linux/omarchy-kanso-theme.git"; ref = "bc405d36b93e0abff39c22eda14d1f33121319f3"; hash = "sha256-AfwCqhF7WMtavS+Z1YTO1YU3XsfGiwDyGhjhzYyvsfY="; defaultBackground = "BG4b.jpg"; };
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

    symlinks = {
      "hypr/theme.lua".source = "hyprland.lua";
      "hypr/hyprlock-theme.conf".source = "hyprlock.conf";
      "waybar/colors.css".source = "waybar.css";
      "walker/themes/kanso/style.css".source = "walker.css";
      "mako/config".source = "mako.ini";
    };
  };

  xdg.configFile."theme-switcher/hooks/theme-set.d/01-notify.sample" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      notify-send -u low "Theme activated" "$1"
    '';
  };
}
