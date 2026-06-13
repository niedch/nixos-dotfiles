{ pkgs, ... }:

let
  capture-screenshot-region = pkgs.writeShellScriptBin "capture-screenshot-region" ''
    grim -g "$(${pkgs.slurp}/bin/slurp)" "$HOME/Pictures/$(date +%Y-%m-%d_%H-%M-%S).png" \
      && ${pkgs.libnotify}/bin/notify-send "Screenshot saved" "$HOME/Pictures/$(date +%Y-%m-%d_%H-%M-%S).png"
  '';

  capture-screenshot-fullscreen = pkgs.writeShellScriptBin "capture-screenshot-fullscreen" ''
    grim "$HOME/Pictures/$(date +%Y-%m-%d_%H-%M-%S).png" \
      && ${pkgs.libnotify}/bin/notify-send "Screenshot saved" "$HOME/Pictures/$(date +%Y-%m-%d_%H-%M-%S).png"
  '';

  capture-screenshot-annotate = pkgs.writeShellScriptBin "capture-screenshot-annotate" ''
    FILE="$HOME/Pictures/$(date +%Y-%m-%d_%H-%M-%S).png"
    ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" "$FILE"
    ${pkgs.satty}/bin/satty --filename "$FILE" --output-filename "$FILE" \
      --actions-on-enter save-to-clipboard --save-after-copy --copy-command 'wl-copy'
  '';

  capture-screenshot-smart = pkgs.writeShellScriptBin "capture-screenshot-smart" ''
    GEOM=$(${pkgs.hyprland}/bin/hyprctl activewindow -j | ${pkgs.jq}/bin/jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')
    ${pkgs.grim}/bin/grim -g "$GEOM" "$HOME/Pictures/$(date +%Y-%m-%d_%H-%M-%S).png" \
      && ${pkgs.libnotify}/bin/notify-send "Screenshot saved"
  '';

  capture-screenshot-text-extract = pkgs.writeShellScriptBin "capture-screenshot-text-extract" ''
    TEMP=$(mktemp /tmp/screenshot-text-extract-XXXXXX.png)
    ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" "$TEMP"
    ${pkgs.tesseract}/bin/tesseract "$TEMP" - | ${pkgs.wl-clipboard}/bin/wl-copy
    ${pkgs.libnotify}/bin/notify-send "Text Extract" "Text copied to clipboard"
    rm -f "$TEMP"
  '';

  capture-screenrecord = pkgs.writeShellScriptBin "capture-screenrecord" ''
    if pgrep -x wf-recorder > /dev/null 2>&1; then
      pkill -SIGINT wf-recorder
      ${pkgs.libnotify}/bin/notify-send "Recording stopped" "Screen recording saved"
    else
      FILE="$HOME/Videos/$(date +%Y-%m-%d_%H-%M-%S).mp4"
      echo "$FILE" > /tmp/wf-recorder-last-file
      ${pkgs.wf-recorder}/bin/wf-recorder -g "$(${pkgs.slurp}/bin/slurp)" -f "$FILE" &>/dev/null &
    fi
    pkill -SIGRTMIN+8 waybar 2>/dev/null || true
  '';

  capture-open-last = pkgs.writeShellScriptBin "capture-open-last" ''
    if [ -f /tmp/wf-recorder-last-file ]; then
      FILE=$(cat /tmp/wf-recorder-last-file)
      if [ -f "$FILE" ]; then
        ${pkgs.mpv}/bin/mpv "$FILE"
      fi
    fi
  '';

  capture-menu = pkgs.writeShellScriptBin "capture-menu" ''
    CHOICE=$(printf "Screenshot Region\nScreenshot Full Screen\nScreenshot Window\nScreenshot + Annotate\nText Extract\nScreen Recording Toggle" | ${pkgs.walker}/bin/walker --dmenu -p "Capture")
    case "$CHOICE" in
      "Screenshot Region")       capture-screenshot-region ;;
      "Screenshot Full Screen")  capture-screenshot-fullscreen ;;
      "Screenshot Window")       capture-screenshot-smart ;;
      "Screenshot + Annotate")   capture-screenshot-annotate ;;
      "Text Extract")            capture-screenshot-text-extract ;;
      "Screen Recording Toggle") capture-screenrecord ;;
    esac
  '';
in
{
  home.packages = with pkgs; [
    grim
    slurp
    satty
    tesseract
    mpv
    wf-recorder
    capture-screenshot-region
    capture-screenshot-fullscreen
    capture-screenshot-annotate
    capture-screenshot-smart
    capture-screenshot-text-extract
    capture-screenrecord
    capture-open-last
    capture-menu
  ];

  xdg.configFile."elephant/menus/capture.lua".text = ''
    Name = "capture"
    NamePretty = "Capture"
    FixedOrder = true

    function GetEntries()
      return {
        {
          Text = "Screenshot Region         ",
          Actions = {
            activate = "capture-screenshot-region",
          },
        },
        {
          Text = "Screenshot Full Screen    ",
          Actions = {
            activate = "capture-screenshot-fullscreen",
          },
        },
        {
          Text = "Screenshot Window         ",
          Actions = {
            activate = "capture-screenshot-smart",
          },
        },
        {
          Text = "Screenshot + Annotate     ",
          Actions = {
            activate = "capture-screenshot-annotate",
          },
        },
        {
          Text = "Text Extract              ",
          Actions = {
            activate = "capture-screenshot-text-extract",
          },
        },
        {
          Text = "Screen Recording Toggle   ",
          Actions = {
            activate = "capture-screenrecord",
          },
        },
      }
    end
  '';
}
