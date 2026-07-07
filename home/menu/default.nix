{
  pkgs,
  lib,
  ...
}: let
  menuWidth = "295";
  menuMaxHeight = "630";

  scripts = [
    {
      name = "launch-or-focus";
      deps = with pkgs; [bash hyprland jq coreutils];
    }
    {
      name = "launch-tui";
      deps = with pkgs; [bash coreutils ghostty];
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
      name = "lock-screen";
      deps = with pkgs; [bash hyprland hyprlock libnotify procps];
    }
    {
      name = "menu-keybindings";
      deps = with pkgs; [
        bash
        gawk
        libxkbcommon
        hyprland
        jq
        gnused
        coreutils
      ];
      selfPath = true;
    }
    {
      name = "menu";
      deps = with pkgs; [
        bash
        coreutils
        hyprpicker
        libnotify
        systemd
        xdg-utils
        pavucontrol
        ghostty
      ];
      envs = {
        WALKER_BIN = "${pkgs.walker}/bin/walker";
        MENU_WIDTH = menuWidth;
        MENU_MAX_HEIGHT = menuMaxHeight;
      };
      selfPath = true;
    }
  ];

  scriptDerivations =
    builtins.map (s: let
      binPath = (lib.optionalString (s.selfPath or false) "$out/bin:") + lib.makeBinPath (s.deps or []);
      envFlags = lib.concatStringsSep " " (
        lib.mapAttrsToList (k: v: ''--set ${k} "${v}"'') (s.envs or {})
      );
    in ''
      cp ${./src}/${s.name}.sh $out/bin/${s.name}
      chmod +x $out/bin/${s.name}
      wrapProgram $out/bin/${s.name} \
        ${envFlags} \
        --prefix PATH : ${binPath}
    '')
    scripts;

  menuScripts =
    pkgs.runCommand "menu-scripts" {
      nativeBuildInputs = [pkgs.makeWrapper];
    } ''
      mkdir -p $out/bin
      ${lib.concatStringsSep "\n" scriptDerivations}
    '';
in {
  home.packages = [
    menuScripts
  ];
}
