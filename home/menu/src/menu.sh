#!/usr/bin/env bash

menu_cmd() {
  local placeholder="$1"
  local options="$2"
  echo -e "$options" | "$WALKER_BIN" --dmenu --width "$MENU_WIDTH" --minheight 1 --maxheight "$MENU_MAX_HEIGHT" --placeholder "$placeholder…"
}

back_to() { "$1"; }

show_main_menu() {
  CHOICE=$(menu_cmd "Go" "Apps\nLearn\nTrigger\nStyle\nSetup\nSystem")
  go_to_menu "$CHOICE"
}

go_to_menu() {
  case "${1,,}" in
    *apps*)        launch-walker ;;
    *learn*)       show_learn_menu ;;
    *trigger*)     show_trigger_menu ;;
    *capture*)     show_capture_menu ;;
    *screenshot*)  show_screenshot_menu ;;
    *screenrecord*) show_screenrecord_menu ;;
    *share*)       show_share_menu ;;
    *style*)       theme-switcher ;;
    *setup*)       show_setup_menu ;;
    *system*)      show_system_menu ;;
    *) ;;
  esac
}

show_learn_menu() {
  CHOICE=$(menu_cmd "Learn" "Keybindings\nHyprland\nNixOS Wiki\nNeovim\nBash")
  case "$CHOICE" in
    *Keybindings*) menu-keybindings ;;
    *Hyprland*)    xdg-open "https://wiki.hyprland.org" ;;
    *NixOS*)       xdg-open "https://wiki.nixos.org" ;;
    *Neovim*)      xdg-open "https://neovim.io/doc/" ;;
    *Bash*)        xdg-open "https://www.gnu.org/software/bash/manual/" ;;
    *) back_to show_main_menu ;;
  esac
}

show_trigger_menu() {
  CHOICE=$(menu_cmd "Trigger" "Capture\nShare\nColor Picker")
  case "$CHOICE" in
    *Capture*) show_capture_menu ;;
    *Share*)   show_share_menu ;;
    *Color*)   hyprpicker -a ;;
    *) back_to show_main_menu ;;
  esac
}

show_capture_menu() {
  CHOICE=$(menu_cmd "Capture" "Screenshot\nScreenrecord")
  case "$CHOICE" in
    *Screenshot*)   show_screenshot_menu ;;
    *Screenrecord*) show_screenrecord_menu ;;
    *) back_to show_trigger_menu ;;
  esac
}

show_screenshot_menu() {
  CHOICE=$(menu_cmd "Screenshot" "Snap with Editing\nStraight to Clipboard")
  case "$CHOICE" in
    *Editing*)   cmd-screenshot smart ;;
    *Clipboard*) cmd-screenshot smart clipboard ;;
    *) back_to show_capture_menu ;;
  esac
}

show_screenrecord_menu() {
  CHOICE=$(menu_cmd "Screenrecord" "Record Screen\nRecord + Desktop Audio\nRecord + Microphone\nRecord + All Audio\nStop Recording")
  case "$CHOICE" in
    *"All Audio"*)    cmd-screenrecord --with-desktop-audio --with-microphone-audio ;;
    *"Desktop Audio"*) cmd-screenrecord --with-desktop-audio ;;
    *Microphone*)     cmd-screenrecord --with-microphone-audio ;;
    *"Record Screen"*) cmd-screenrecord ;;
    *Stop*)           cmd-screenrecord --stop-recording ;;
    *) back_to show_capture_menu ;;
  esac
}

show_share_menu() {
  CHOICE=$(menu_cmd "Share" "Clipboard\nFile\nFolder")
  case "$CHOICE" in
    *Clipboard*) cmd-share clipboard ;;
    *File*)      ghostty --class="org.tui.share" -- bash -c "cmd-share file" ;;
    *Folder*)    ghostty --class="org.tui.share" -- bash -c "cmd-share folder" ;;
    *) back_to show_trigger_menu ;;
  esac
}

show_setup_menu() {
  CHOICE=$(menu_cmd "Setup" "Audio\nWifi\nBluetooth")
  case "$CHOICE" in
    *Audio*)     pavucontrol & ;;
    *Wifi*)      launch-or-focus-tui wlctl ;;
    *Bluetooth*) launch-or-focus-tui bluetui ;;
    *) back_to show_main_menu ;;
  esac
}

show_system_menu() {
  if pgrep -x hypridle >/dev/null; then
    IDLE_LABEL="Inhibit Idle"
  else
    IDLE_LABEL="Enable Idle"
  fi

  CHOICE=$(menu_cmd "System" "Lock\n$IDLE_LABEL\nLogout\nSuspend\nRestart\nShutdown")
  case "$CHOICE" in
    *"Inhibit"*)   toggle-idle --off ;;
    *"Enable"*)    toggle-idle --on ;;
    *Lock*)        lock-screen ;;
    *Logout*)      cmd-logout ;;
    *Suspend*)     systemctl suspend ;;
    *Restart*)     cmd-reboot ;;
    *Shutdown*)    cmd-shutdown ;;
    *) back_to show_main_menu ;;
  esac
}

if [[ -n "$1" ]]; then
  go_to_menu "$1"
else
  show_main_menu
fi
