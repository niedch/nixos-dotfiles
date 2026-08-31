{pkgs}: [
  {
    name = "launch-or-focus";
    deps = with pkgs; [bash hyprland jq coreutils util-linux];
  }
  {
    name = "launch-tui";
    deps = with pkgs; [bash coreutils ghostty util-linux];
  }
  {
    name = "launch-or-focus-tui";
    deps = with pkgs; [bash coreutils];
    selfPath = true;
  }
  {
    name = "cmd-screenshot";
    deps = with pkgs; [
      bash
      coreutils
      jq
      gawk
      procps
      hyprland
      grim
      slurp
      wl-clipboard
      wayfreeze
      libnotify
      satty
    ];
  }
  {
    name = "cmd-screenrecord";
    deps = with pkgs; [
      bash
      coreutils
      jq
      procps
      hyprland
      wl-screenrec
      pulseaudio
      libnotify
    ];
  }
  {
    name = "cmd-share";
    deps = with pkgs; [
      bash
      coreutils
      wl-clipboard
      libnotify
      systemd
      fzf
      localsend
    ];
  }
  {
    name = "cmd-logout";
    deps = with pkgs; [bash hyprland jq coreutils];
  }
  {
    name = "cmd-reboot";
    deps = with pkgs; [bash hyprland jq coreutils systemd];
  }
  {
    name = "cmd-shutdown";
    deps = with pkgs; [bash hyprland jq coreutils systemd];
  }
  {
    name = "toggle-idle";
    deps = with pkgs; [bash procps coreutils systemd libnotify];
  }
  {
    name = "toggle-sunset";
    deps = with pkgs; [bash procps coreutils hyprsunset libnotify];
  }
  {
    name = "lock-screen";
    deps = with pkgs; [bash hyprland hyprlock libnotify procps];
  }
  {
    name = "cmd-timer";
    deps = with pkgs; [bash coreutils ghostty libnotify gum gnugrep systemd];
  }
  {
    name = "qs-shell";
    deps = with pkgs; [bash quickshell coreutils gawk procps];
  }
  {
    name = "toggle-dnd";
    deps = with pkgs; [bash coreutils quickshell gawk];
  }
  {
    name = "toggle-touchpad";
    deps = with pkgs; [bash coreutils hyprland jq];
  }
]
