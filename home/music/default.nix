{pkgs, config, ...}: let
  writableSpotify = "${config.home.homeDirectory}/.local/share/spicetify/Spotify";

  spicetify = pkgs.writeShellScriptBin "spicetify" ''
    set -euo pipefail
    WRITABLE="${writableSpotify}"
    NIX_SPOTIFY="${pkgs.spotify}"
    CONFIG="$HOME/.config/spicetify/config-xpui.ini"

    mkdir -p "$(dirname "$CONFIG")"

    SOURCE_FILE="$WRITABLE/.nix-source"
    if [ ! -f "$SOURCE_FILE" ] || [ "$(cat "$SOURCE_FILE")" != "$NIX_SPOTIFY" ]; then
      echo "Setting up writable Spotify copy for Spicetify..." >&2
      rm -rf "$WRITABLE"
      mkdir -p "$WRITABLE"
      cp -r "$NIX_SPOTIFY"/* "$WRITABLE"/
      chmod -R u+w "$WRITABLE"
      ${pkgs.gnused}/bin/sed -i "s|$NIX_SPOTIFY/|$WRITABLE/|g" "$WRITABLE/bin/spotify"
      echo "$NIX_SPOTIFY" > "$SOURCE_FILE"
    fi

    if [ ! -f "$CONFIG" ]; then
      cat > "$CONFIG" << EOF
[Setting]
spotify_path = $WRITABLE/share/spotify
current_theme = Omarchy
inject_css = 1
inject_theme_js = 1
replace_colors = 1
overwrite_assets = 0
check_spicetify_update = 0
EOF
    fi

    ${pkgs.gnused}/bin/sed -i "s|^spotify_path *=.*|spotify_path = $WRITABLE/share/spotify|" "$CONFIG"
    exec ${pkgs.spicetify-cli}/bin/spicetify "$@"
  '';

  spotify = pkgs.writeShellScriptBin "spotify" ''
    EXEC_BIN="${writableSpotify}/bin/spotify"
    if [ ! -x "$EXEC_BIN" ]; then
      echo "Spotify not ready yet — run 'spicetify backup apply' first." >&2
      exit 1
    fi
    exec "$EXEC_BIN" --remote-debugging-port=9222 --remote-allow-origins=* "$@"
  '';

  spotifyAssets = pkgs.runCommandLocal "spotify-assets" {} ''
    mkdir -p $out/share/applications $out/share/icons
    cp -r ${pkgs.spotify}/share/applications/* $out/share/applications/
    cp -r ${pkgs.spotify}/share/icons/* $out/share/icons/
  '';
in {
  home.packages = [
    spotify        # our wrapper → provides bin/spotify
    spotifyAssets  # desktop entry + icons from pkgs.spotify (no conflict)
    spicetify
  ];
}
