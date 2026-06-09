{ pkgs, ... }:

let
  omarchy-launch-walker = pkgs.writeShellScriptBin "omarchy-launch-walker" ''
    GSK_RENDERER=cairo exec ${pkgs.walker}/bin/walker \
      --width 644 --maxheight 300 --minheight 300 "$@"
  '';

  omarchy-restart-walker = pkgs.writeShellScriptBin "omarchy-restart-walker" ''
    systemctl --user restart elephant.service walker.service
  '';
in
{
  home.packages = [ pkgs.walker pkgs.elephant omarchy-launch-walker omarchy-restart-walker ];

  xdg.configFile."walker/config.toml".source = ./config.toml;
  xdg.configFile."walker/themes/kanso/layout.xml".source = ./kanso-layout.xml;

  xdg.configFile."elephant/calc.toml".source = ./elephant/calc.toml;
  xdg.configFile."elephant/desktopapplications.toml".source = ./elephant/desktopapplications.toml;
  xdg.configFile."elephant/symbols.toml".source = ./elephant/symbols.toml;

  xdg.configFile."elephant/menus/omarchy_background_selector.lua".text = ''
    Name = "omarchyBackgroundSelector"
    NamePretty = "Omarchy Background Selector"
    Cache = false
    HideFromProviderlist = true
    SearchName = true

    function GetEntries()
      return {
        {
          Text = "Kanso 1",
          Value = "/dev/null",
        },
        {
          Text = "Kanso 2",
          Value = "/dev/null",
        },
      }
    end
  '';

  xdg.configFile."elephant/menus/omarchy_themes.lua".text = ''
    Name = "omarchythemes"
    NamePretty = "Omarchy Themes"
    HideFromProviderlist = true
    SearchName = true

    function GetEntries()
      return {
        {
          Text = "Kanso  ",
          Value = "kanso",
          Actions = {
            activate = "echo 'Theme switching not wired yet'",
          },
        },
      }
    end
  '';

  xdg.configFile."elephant/menus/omarchy_unlocks.lua".text = ''
    Name = "omarchyunlocks"
    NamePretty = "Omarchy Unlocks"
    HideFromProviderlist = true
    FixedOrder = true

    function GetEntries()
      return {
        {
          Text = "Default  ",
          Actions = {
            activate = "notify-send 'Unlock themes not wired yet'",
          },
        },
      }
    end
  '';
  systemd.user.services.elephant = {
    Unit = {
      Description = "Elephant launcher backend";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
      ConditionEnvironment = "WAYLAND_DISPLAY";
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.elephant}/bin/elephant";
      Restart = "on-failure";
      RestartSec = 1;
      ExecStopPost = "${pkgs.coreutils}/bin/rm -f /tmp/elephant.sock";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  systemd.user.services.walker = {
    Unit = {
      Description = "Walker - Application Runner";
      ConditionEnvironment = "WAYLAND_DISPLAY";
      After = [ "graphical-session.target" "elephant.service" ];
      Requires = [ "elephant.service" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Environment = "GSK_RENDERER=cairo";
      ExecStart = "${pkgs.walker}/bin/walker --gapplication-service";
      Restart = "always";
      RestartSec = 2;
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
