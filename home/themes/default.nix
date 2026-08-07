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
  omarchyRef = "88ef6ca597929aa7ea6ca198a404821ad64f9714";
in let
  yaruTheme = inputs.yaru-nixpkgs.legacyPackages.${pkgs.system}.yaru-theme;
in {
  imports = [inputs.nix-omarchy-theme.homeManagerModules.default];

  omarchy-themes = {
    enable = true;
    defaultTheme = "koyanagi";
    iconPackages = with pkgs; [ adwaita-icon-theme yaruTheme ];

    themes = {
      catppuccin-latte = {
        url = omarchyRepo;
        rev = omarchyRef;
        subpath = "themes/catppuccin-latte";
      };
      catppuccin = {
        url = omarchyRepo;
        rev = omarchyRef;
        subpath = "themes/catppuccin";
      };
      ethereal = {
        url = omarchyRepo;
        rev = omarchyRef;
        subpath = "themes/ethereal";
      };
      everforest = {
        url = omarchyRepo;
        rev = omarchyRef;
        subpath = "themes/everforest";
      };
      gruvbox = {
        url = omarchyRepo;
        rev = omarchyRef;
        subpath = "themes/gruvbox";
      };
      kanso = {
        url = "https://github.com/HANCORE-linux/omarchy-kanso-theme.git";
        rev = "bc405d36b93e0abff39c22eda14d1f33121319f3";
        defaultBackground = "BG4b.jpg";
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
        rev = "612e122cfc0e3475559e081ca41cd99d2356b4a3";
        defaultBackground = "BG3.jpg";
      };
      the-greek = {
        url = "https://github.com/HANCORE-linux/omarchy-thegreek-theme.git";
        rev = "c2129dd8b17ae64e54a43d6e714eb9d66876edae";
        mode = "light";
      };
      koyanagi = {
        url = "https://github.com/niedch/omarchy-koyanagi-theme";
        rev = "b40d7875b661f42525e9c916406f86de7449b2fa";
        defaultBackground = "background_3.jpg";
      };
      last-horizon = {
        url = omarchyRepo;
        rev = omarchyRef;
        subpath = "themes/last-horizon";
      };
      matte-black = {
        url = omarchyRepo;
        rev = omarchyRef;
        subpath = "themes/matte-black";
      };
      miasma = {
        url = omarchyRepo;
        rev = omarchyRef;
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
        rev = omarchyRef;
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
        rev = omarchyRef;
        subpath = "themes/ristretto";
      };
      rose-pine = {
        url = omarchyRepo;
        rev = omarchyRef;
        subpath = "themes/rose-pine";
      };
      solitude = {
        url = omarchyRepo;
        rev = omarchyRef;
        subpath = "themes/solitude";
      };
      tokyo-night = {
        url = omarchyRepo;
        rev = omarchyRef;
        subpath = "themes/tokyo-night";
      };
      vantablack = {
        url = omarchyRepo;
        rev = omarchyRef;
        subpath = "themes/vantablack";
      };
      white = {
        url = omarchyRepo;
        rev = omarchyRef;
        subpath = "themes/white";
      };
    };

    selectorCommand = "false";

    templates."quickshell.colors.json.tpl" = ''
      {
        "background": "{{ background }}",
        "foreground": "{{ foreground }}",
        "cursor": "{{ cursor }}",
        "accent": "{{ accent }}",
        "selectionBackground": "{{ selection_background }}",
        "selectionForeground": "{{ selection_foreground }}",
        "color0": "{{ color0 }}",
        "color1": "{{ color1 }}",
        "color2": "{{ color2 }}",
        "color3": "{{ color3 }}",
        "color4": "{{ color4 }}",
        "color5": "{{ color5 }}",
        "color6": "{{ color6 }}",
        "color7": "{{ color7 }}",
        "color8": "{{ color8 }}",
        "color9": "{{ color9 }}",
        "color10": "{{ color10 }}",
        "color11": "{{ color11 }}",
        "color12": "{{ color12 }}",
        "color13": "{{ color13 }}",
        "color14": "{{ color14 }}",
        "color15": "{{ color15 }}"
      }
    '';

    symlinks = {
      "hypr/theme.lua".source = "hyprland.lua";
      "quickshell/colors.json".source = "quickshell.colors.json";
      "hypr/hyprlock-theme.conf".source = "hyprlock.conf";
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
      "05_quickshell_reload" = ''
        quickshell-reload-theme 2>/dev/null || true
      '';
    };
  };
}
