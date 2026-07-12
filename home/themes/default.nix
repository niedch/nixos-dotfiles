# To update a theme's ref and hash:
#   1. Set hash to "" (empty string)
#   2. Run: nix build .#homeConfigurations.<name>.activationPackage 2>&1 | grep "got:"
#   3. Copy the suggested hash back into this file
#   Or use: nix-prefetch-git <url> <ref>
{
  inputs,
  pkgs,
  ...
}: let
  omarchyRepo = "https://github.com/basecamp/omarchy.git";
  omarchyRef = "9cf1852525a5f7de26d3162db9d61e2f5c1d5523";
  omarchyHash = "sha256-9zkIEgD/L5+eK5fuQNXbBd5XXO+NwH6QWGiDI//kGas=";
in {
  imports = [inputs.nix-omarchy-theme.homeManagerModules.default];

  omarchy-themes = {
    enable = true;
    defaultTheme = "koyanagi";

    themes = {
      catppuccin-latte = {
        url = omarchyRepo;
        ref = omarchyRef;
        hash = omarchyHash;
        subpath = "themes/catppuccin-latte";
      };
      catppuccin = {
        url = omarchyRepo;
        ref = omarchyRef;
        hash = omarchyHash;
        subpath = "themes/catppuccin";
      };
      ethereal = {
        url = omarchyRepo;
        ref = omarchyRef;
        hash = omarchyHash;
        subpath = "themes/ethereal";
      };
      everforest = {
        url = omarchyRepo;
        ref = omarchyRef;
        hash = omarchyHash;
        subpath = "themes/everforest";
      };
      gruvbox = {
        url = omarchyRepo;
        ref = omarchyRef;
        hash = omarchyHash;
        subpath = "themes/gruvbox";
      };
      kanso = {
        url = "https://github.com/HANCORE-linux/omarchy-kanso-theme.git";
        ref = "bc405d36b93e0abff39c22eda14d1f33121319f3";
        hash = "sha256-AfwCqhF7WMtavS+Z1YTO1YU3XsfGiwDyGhjhzYyvsfY=";
        defaultBackground = "BG_Painting.jpg";
        extraBackgrounds = [
          {
            url = "https://w.wallhaven.cc/full/3q/wallhaven-3qrdr6.jpg";
            hash = "sha256-sDmF+oM7eMsT+3W9fgdGbN0hAi7IeIAl/IhlAYo1CK8=";
            filename = "BG_Painting.jpg";
          }
        ];
      };
      mechanoona = {
        url = "https://github.com/HANCORE-linux/omarchy-mechanoonna-theme.git";
        ref = "612e122cfc0e3475559e081ca41cd99d2356b4a3";
        hash = "sha256-IxzTwblsoGFPFsRQXcPE4VsM+S4mAOKhPMhUASUmVOU=";
        defaultBackground = "BG3.jpg";
      };
      the-greek = {
        url = "https://github.com/HANCORE-linux/omarchy-thegreek-theme.git";
        ref = "c2129dd8b17ae64e54a43d6e714eb9d66876edae";
        hash = "sha256-njw+hvqZUZXxzuu7kMxWV/ez6gKWEyy3nFr6TxsAlyk=";
      };
      koyanagi = {
        url = "https://github.com/YutaKoyanagi10/omarchy-koyanagi-theme.git";
        ref = "a09f41ab0a4d2d2e5a5647c0c40ca092cf67b816";
        hash = "sha256-95XZzgiDxkxD3nCJneaNL27iJR5bdwtIKtPWbokSpcI=";
        defaultBackground = "background_3.jpg";
      };
      last-horizon = {
        url = omarchyRepo;
        ref = omarchyRef;
        hash = omarchyHash;
        subpath = "themes/last-horizon";
      };
      matte-black = {
        url = omarchyRepo;
        ref = omarchyRef;
        hash = omarchyHash;
        subpath = "themes/matte-black";
      };
      miasma = {
        url = omarchyRepo;
        ref = omarchyRef;
        hash = omarchyHash;
        subpath = "themes/miasma";
        defaultBackground = "03-house.jpg";
        extraBackgrounds = [
          {
            url = "https://w.wallhaven.cc/full/je/wallhaven-jexkwm.jpg";
            hash = "sha256-RIwA/16yaZiBy7b0pUDBl12QeI/kAajUAY9Vu6e18r4=";
            filename = "03-house.jpg";
          }
        ];
      };
      nord = {
        url = omarchyRepo;
        ref = omarchyRef;
        hash = omarchyHash;
        subpath = "themes/nord";
        defaultBackground = "wallhaven-5yr1p8.png";
        extraBackgrounds = [
          {
            url = "https://w.wallhaven.cc/full/vm/wallhaven-vmdpd5.jpg";
            hash = "sha256-2qkUwLAvqEegpMZqWnJmnI7VhV2+AGj4ALecHisc+YY=";
            filename = "3-Snow.jpg";
          }
        ];
      };
      ristretto = {
        url = omarchyRepo;
        ref = omarchyRef;
        hash = omarchyHash;
        subpath = "themes/ristretto";
      };
      rose-pine = {
        url = omarchyRepo;
        ref = omarchyRef;
        hash = omarchyHash;
        subpath = "themes/rose-pine";
      };
      solitude = {
        url = omarchyRepo;
        ref = omarchyRef;
        hash = omarchyHash;
        subpath = "themes/solitude";
      };
      tokyo-night = {
        url = omarchyRepo;
        ref = omarchyRef;
        hash = omarchyHash;
        subpath = "themes/tokyo-night";
      };
      vantablack = {
        url = omarchyRepo;
        ref = omarchyRef;
        hash = omarchyHash;
        subpath = "themes/vantablack";
      };
      white = {
        url = omarchyRepo;
        ref = omarchyRef;
        hash = omarchyHash;
        subpath = "themes/white";
      };
    };

    selectorCommand = "walker --dmenu";

    symlinks = {
      "hypr/theme.lua".source = "hyprland.lua";
      "hypr/hyprlock-theme.conf".source = "hyprlock.conf";
      "waybar/colors.css".source = "waybar.css";
      "walker/themes/default/walker.css".source = "walker.css";
      "mako/config".source = "mako.ini";
      "btop/themes/btop.theme".source = "btop.theme";
      "gtk-3.0/settings.ini" = {
        source = "settings-3.0.ini";
        recursive = false;
      };
      "gtk-4.0/settings.ini" = {
        source = "settings-4.0.ini";
        recursive = false;
      };
      "gtk-3.0/gtk.css".source = "gtk.css";
      "gtk-4.0/gtk.css".source = "gtk.css";
      "spicetify/Themes/Omarchy/color.ini".source = "color.ini";
    };

    afterHooks = {
      "04_spicetify_apply" = ''
        spicetify -s refresh 2>/dev/null || spicetify -n backup apply 2>/dev/null || true
        for PORT in 9222 8088; do
          WS_URL=$(curl -sf http://localhost:$PORT/json/list 2>/dev/null | \
            ${pkgs.jq}/bin/jq -r '.[] | select(.url | contains("spotify")) | .webSocketDebuggerUrl' 2>/dev/null || true)
          if [ -n "$WS_URL" ]; then break; fi
        done
        if [ -n "$WS_URL" ]; then
          echo '{"id":0,"method":"Runtime.evaluate","params":{"expression":"window.location.reload()"}}' | \
            ${pkgs.websocat}/bin/websocat "$WS_URL" 2>/dev/null || true
        fi
      '';
    };
  };
}
