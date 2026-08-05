var menuTree = [
  // ─────────────── Apps ───────────────
  { label: "Apps", icon: "󰘔", kind: "action", action: "launch-apps" },

  // ─────────────── Learn ───────────────
  { label: "Learn", icon: "󰊩", kind: "group", children: [
    { label: "Keybindings",   icon: "⌨",  kind: "action", action: "keybindings" },
    { label: "Hyprland Wiki", icon: "󰖳",  kind: "action", action: "url", url: "https://wiki.hyprland.org" },
    { label: "NixOS Wiki",    icon: "󱄅",  kind: "action", action: "url", url: "https://wiki.nixos.org" },
    { label: "Neovim Docs",   icon: "󰵀",  kind: "action", action: "url", url: "https://neovim.io/doc/" },
    { label: "Bash Manual",   icon: "󰌢",  kind: "action", action: "url", url: "https://www.gnu.org/software/bash/manual/" },
  ]},

  // ─────────────── Capture ───────────────
  { label: "Capture", icon: "󰇂", kind: "group", children: [
    { label: "Screenshot", icon: "󰆟", kind: "group", children: [
      { label: "Snap with Editing",     icon: "󰏬", kind: "action", action: "exec", cmd: ["cmd-screenshot", "smart"] },
      { label: "Straight to Clipboard", icon: "󰆏", kind: "action", action: "exec", cmd: ["cmd-screenshot", "smart", "clipboard"] },
    ]},
    { label: "Screenrecord", icon: "󰀽", kind: "group", children: [
      { label: "Record Screen",          icon: "󰨊", kind: "action", action: "exec", cmd: ["cmd-screenrecord"] },
      { label: "Record + Desktop Audio", icon: "󰋋", kind: "action", action: "exec", cmd: ["cmd-screenrecord", "--with-desktop-audio"] },
      { label: "Record + Microphone",    icon: "󰍬", kind: "action", action: "exec", cmd: ["cmd-screenrecord", "--with-microphone-audio"] },
      { label: "Record + All Audio",     icon: "󰋎", kind: "action", action: "exec", cmd: ["cmd-screenrecord", "--with-desktop-audio", "--with-microphone-audio"] },
      { label: "Stop Recording",         icon: "󰓛", kind: "action", action: "exec", cmd: ["cmd-screenrecord", "--stop-recording"] },
    ]},
    { label: "Timer", icon: "⏱", kind: "group", children: [
      { label: "Set Timer", icon: "⏱", kind: "action", action: "exec", cmd: ["launch-tui", "cmd-timer"] },
    ]},
  ]},

  // ─────────────── Share ───────────────
  { label: "Share", icon: "󰈁", kind: "group", children: [
    { label: "Clipboard", icon: "󰆏", kind: "action", action: "exec", cmd: ["cmd-share", "clipboard"] },
    { label: "File",      icon: "󰈔", kind: "action", action: "exec", cmd: ["ghostty", "--class=org.tui.share", "--", "bash", "-c", "cmd-share file"] },
    { label: "Folder",    icon: "󰉋", kind: "action", action: "exec", cmd: ["ghostty", "--class=org.tui.share", "--", "bash", "-c", "cmd-share folder"] },
  ]},

  // ─────────────── Tools ───────────────
  { label: "Color Picker", icon: "󰋞", kind: "action", action: "exec", cmd: ["hyprpicker", "-a"] },

  // ─────────────── Themes ───────────────
  { label: "Themes", icon: "󰉼", kind: "themes" },

  // ─────────────── Setup ───────────────
  { label: "Setup", icon: "󰒓", kind: "group", children: [
    { label: "Audio",     icon: "󰕾", kind: "action", action: "exec", cmd: ["launch-or-focus-tui", "wiremix"] },
    { label: "WiFi",      icon: "󰖩", kind: "action", action: "exec", cmd: ["launch-or-focus-tui", "wlctl"] },
    { label: "Bluetooth", icon: "󰂯", kind: "action", action: "exec", cmd: ["launch-or-focus-tui", "bluetui"] },
  ]},

  // ─────────────── System ───────────────
  { label: "System", icon: "󰔟", kind: "group", children: [
    { label: "Lock",        icon: "󰌾", kind: "action", action: "exec", cmd: ["lock-screen"] },
    { label: "Toggle Idle", icon: "󱫖", kind: "action", dynamic: true },
    { label: "Logout",      icon: "󰍃", kind: "action", danger: true, action: "exec", cmd: ["cmd-logout"] },
    { label: "Suspend",     icon: "󰤄", kind: "action", danger: true, action: "exec", cmd: ["systemctl", "suspend"] },
    { label: "Restart",     icon: "󰜉", kind: "action", danger: true, action: "exec", cmd: ["cmd-reboot"] },
    { label: "Shutdown",    icon: "󰐥", kind: "action", danger: true, action: "exec", cmd: ["cmd-shutdown"] },
  ]},
]
