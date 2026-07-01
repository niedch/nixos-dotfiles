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
    defaultTheme = "kanso";

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
        defaultBackground = "6-houses.png";
        extraBackgrounds = [
          {
            url = "https://w.wallhaven.cc/full/9m/wallhaven-9mj8yw.png";
            hash = "sha256-m+CJrkoRp48ZY8LHBWBN7MnxWReLKxkKweKWdOvg1Fg=";
            filename = "6-houses.png";
          }
        ];
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
          {
            url = "https://w.wallhaven.cc/full/6l/wallhaven-6lwr2x.jpg";
            hash = "sha256-qGpudZv+1GeBfjd/LWOZmGZTn/KayjxpZw4zSKLwdpA=";
            filename = "BG_Tirol.jpg";
          }
          {
            url = "https://w.wallhaven.cc/full/3q/wallhaven-3qr15y.jpg";
            hash = "sha256-IHhL4heE3ON+PGvY+Nwz9qyIPb8Cq56rHjtlByrJkDc=";
            filename = "BG_SW_Scoul.jpg";
          }
        ];
      };
      mechanoona = {
        url = "https://github.com/HANCORE-linux/omarchy-mechanoonna-theme.git";
        ref = "612e122cfc0e3475559e081ca41cd99d2356b4a3";
        hash = "sha256-fr0swq4pXBVxzCxv8pK5rj9v3ed2DMKFjkvfq6cE2ro=";
        defaultBackground = "BG3.jpg";
      };
      the-greek = {
        url = "https://github.com/HANCORE-linux/omarchy-thegreek-theme.git";
        ref = "c2129dd8b17ae64e54a43d6e714eb9d66876edae";
        hash = "sha256-C9YnCkbVS17h10MoE+Z34HmSVd6/hoE+svNDTO3ZXTA=";
      };
      koyanagi = {
        url = "https://github.com/YutaKoyanagi10/omarchy-koyanagi-theme.git";
        ref = "a09f41ab0a4d2d2e5a5647c0c40ca092cf67b816";
        hash = "sha256-95XZzgiDxkxD3nCJneaNL27iJR5bdwtIKtPWbokSpcI=";
      };
      last-horizon = {
        url = omarchyRepo;
        ref = omarchyRef;
        hash = omarchyHash;
        subpath = "themes/last-horizon";
      };
      lumon = {
        url = omarchyRepo;
        ref = omarchyRef;
        hash = omarchyHash;
        subpath = "themes/lumon";
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
      osaka-jade = {
        url = omarchyRepo;
        ref = omarchyRef;
        hash = omarchyHash;
        subpath = "themes/osaka-jade";
      };
      retro-82 = {
        url = omarchyRepo;
        ref = omarchyRef;
        hash = omarchyHash;
        subpath = "themes/retro-82";
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
    };

    # afterHooks = {
    #   "07_reload_chromium_policy" = ''
    #     CURRENT="''${CURRENT:-$HOME/.local/share/themes/current}"
    #     if [ -f "$CURRENT/chromium-policy.json" ]; then
    #       mkdir -p "$HOME/.config/chromium/policies/managed"
    #       cat "$CURRENT/chromium-policy.json" > "$HOME/.config/chromium/policies/managed/color.json"
    #     fi
    #   '';
    # };
  };
}
