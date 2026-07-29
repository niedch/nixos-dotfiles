{
  lib,
  pkgs,
  config,
  inputs,
  ...
}: let
  cfg = config.nixosDotfiles.noctalia;

  noctalia = cmd: ["noctalia" "msg"] ++ (pkgs.lib.splitString " " cmd);
in {
  imports = [
    inputs.niri.homeModules.niri
    inputs.noctalia.homeModules.default
  ];

  options.nixosDotfiles.noctalia.enable =
    lib.mkEnableOption "Noctalia shell on Niri as a trial login session";

  config = lib.mkIf cfg.enable {
    programs.niri = {
      enable = true;
      # Pin to the nixpkgs niri so we use cache.nixos.org instead of
      # building niri from the niri-flake sources (and needing its cachix).
      package = pkgs.niri;
      settings = {
        prefer-no-csd = true;
        hotkey-overlay.skip-at-startup = true;

        layout = {
          gaps = 8;
          focus-ring = {
            enable = true;
            width = 2;
            active.color = "#A8AEFF";
            inactive.color = "#505050";
          };
        };

        input = {
          keyboard.xkb.layout = "us";
          touchpad = {
            tap = true;
            natural-scroll = true;
            click-method = "button-areas";
            dwt = true;
          };
          focus-follows-mouse.enable = true;
        };

        environment = {
          NIXOS_OZONE_WL = "1";
          MOZ_ENABLE_WAYLAND = "1";
          GDK_BACKEND = "wayland,x11";
          QT_QPA_PLATFORM = "wayland";
          ELECTRON_OZONE_PLATFORM_HINT = "auto";
          XDG_SESSION_TYPE = "wayland";
          XDG_CURRENT_DESKTOP = "niri";
        };

        spawn-at-startup = [
          {command = ["noctalia"];}
        ];

        binds = with config.lib.niri.actions; {
          "Mod+Return".action = spawn "ghostty";
          "Mod+B".action = spawn "chromium";
          "Mod+Space".action.spawn = noctalia "panel-toggle launcher";
          "Mod+Q".action = close-window;
          "Mod+F".action = fullscreen-window;
          "Mod+T".action = toggle-window-floating;
          "Mod+L".action.spawn = noctalia "session lock";
          "Mod+Shift+P".action.power-off-monitors = [];
          "Control+Alt+Delete".action.quit = [];

          "XF86AudioRaiseVolume".action.spawn = noctalia "volume-up";
          "XF86AudioLowerVolume".action.spawn = noctalia "volume-down";
          "XF86AudioMute".action.spawn = noctalia "volume-mute";
          "XF86AudioPlay".action.spawn = noctalia "media toggle";
          "XF86AudioNext".action.spawn = noctalia "media next";
          "XF86AudioPrev".action.spawn = noctalia "media previous";

          "Mod+Left".action = focus-column-left;
          "Mod+Right".action = focus-column-right;
          "Mod+Down".action = focus-workspace-down;
          "Mod+Up".action = focus-workspace-up;

          "Mod+Shift+Left".action = move-column-left;
          "Mod+Shift+Right".action = move-column-right;
          "Mod+Shift+Down".action = move-column-to-workspace-down;
          "Mod+Shift+Up".action = move-column-to-workspace-up;

          "Control+Shift+1".action.screenshot = [];
          "Control+Shift+2".action.screenshot-window = [];
        };
      };
    };

    programs.noctalia = {
      enable = true;
      # Noctalia is started by niri spawn-at-startup, so there is no point
      # in an extra systemd user service (which would also start under Hyprland).
      systemd.enable = false;
      # Skip running the noctalia binary at build time for config validation.
      validateConfig = false;
    };
  };
}