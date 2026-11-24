{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.librepods;
in {
  options.services.librepods = {
    enable = lib.mkEnableOption "LibrePods AirPods daemon";
    package = lib.mkPackageOption pkgs "librepods" {};
  };

  config = lib.mkIf cfg.enable {
    home.packages = [cfg.package];

    systemd.user.services.librepods = {
      Unit = {
        Description = "LibrePods AirPods daemon";
        After = ["graphical-session.target"];
        PartOf = ["graphical-session.target"];
      };

      Service = {
        Type = "simple";
        Environment = ["QT_LOGGING_RULES=openpods.debug=false"];
        ExecStart = "${cfg.package}/bin/librepods --hide";
        Restart = "on-failure";
        RestartSec = 5;
      };

      Install = {
        WantedBy = ["graphical-session.target"];
      };
    };
  };
}
