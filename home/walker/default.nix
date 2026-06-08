{ pkgs, ... }:

let
  walkerConfig = pkgs.formats.toml { }.generate "config.toml" {
    theme = "kanso";
    close_when_open = true;
    single_click_activation = true;
    as_window = false;
    placeholders.default = { input = "Search"; list = "No Results"; };
  };
in
{
  home.packages = [ pkgs.walker pkgs.elephant ];

  xdg.configFile."walker/config.toml".source = walkerConfig;

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
      ExecStart = "${pkgs.walker}/bin/walker --gapplication-service";
      Restart = "on-failure";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
