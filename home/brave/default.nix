{ pkgs, ... }:

let
  favicon-fetch = pkgs.writeShellApplication {
    name = "favicon-fetch";
    runtimeInputs = [ pkgs.curl pkgs.imagemagick ];
    text = ''
      set -euo pipefail

      if [ $# -ne 2 ]; then
        echo "Usage: favicon-fetch <name> <url>"
        exit 1
      fi

      name=$1
      url=$2

      if [[ ! $url =~ ^[a-zA-Z][a-zA-Z0-9+.-]*: ]]; then
        url="https://$url"
      fi

      reporoot=$(git rev-parse --show-toplevel 2>/dev/null || echo "$HOME/Projects/nixos-dotfiles")
      outdir="$reporoot/home/brave/icons"
      mkdir -p "$outdir"
      output="$outdir/''${name}.png"

      domain=$(echo "$url" | sed 's|https\?://||; s|/.*||')
      api_url="https://www.google.com/s2/favicons?domain=$domain&sz=128"

      echo "Fetching favicon for $domain ..."
      if ! curl -fsSL -o "$output" "$api_url" || [ ! -s "$output" ]; then
        echo "Error: Failed to fetch favicon from $api_url"
        exit 1
      fi

      mime=$(file -b --mime-type "$output" 2>/dev/null || echo "")
      if [ "$mime" = "image/x-icon" ] || [ "$mime" = "image/vnd.microsoft.icon" ]; then
        echo "Converting ICO to PNG ..."
        tmp=$(mktemp)
        convert "$output" -resize 256x256 PNG32:"$tmp" && mv "$tmp" "$output"
      fi

      echo "$(wc -c < "$output" | tr -d ' ') bytes written to $output"
    '';
  };

in
{
  xdg.desktopEntries.Github = {
    name = "Github";
    exec = "${pkgs.brave}/bin/brave --app=https://www.github.com";
    icon = "${./icons/github.png}";
    terminal = false;
    type = "Application";
    categories = [ "Network" "WebBrowser" ];
  };

  xdg.desktopEntries.Slack = {
    name = "Slack";
    exec = "${pkgs.brave}/bin/brave --app=https://app.slack.com/client/T2M6RN37H/C2M6Y5066";
    icon = "${./icons/slack.png}";
    terminal = false;
    type = "Application";
    categories = [ "Network" "WebBrowser" ];
  };

  xdg.desktopEntries.Gmail = {
    name = "Gmail";
    exec = "${pkgs.brave}/bin/brave --app=https://mail.google.com/mail/u/0";
    icon = "${./icons/gmail.png}";
    terminal = false;
    type = "Application";
    categories = [ "Network" "WebBrowser" ];
  };

  xdg.desktopEntries.Gdrive = {
    name = "Google Drive";
    exec = "${pkgs.brave}/bin/brave --app=https://drive.google.com/drive/home";
    icon = "${./icons/gdrive.png}";
    terminal = false;
    type = "Application";
    categories = [ "Network" "WebBrowser" ];
  };
  home.packages = [ favicon-fetch ];

  programs.brave = {
    enable = true;

    commandLineArgs = [
      "--enable-features=BraveVerticalTab"
    ];

    extensions = [
      { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; }   # uBlock Origin
    ];
  };
}
