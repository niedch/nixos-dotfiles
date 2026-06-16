{pkgs, ...}: let
  launch-walker = pkgs.writeShellScriptBin "launch-walker" ''
    GSK_RENDERER=cairo exec ${pkgs.walker}/bin/walker "$@"
  '';

  restart-walker = pkgs.writeShellScriptBin "omarchy-restart-walker" ''
    systemctl --user restart elephant.service walker.service
  '';
in {
  home.packages = [
    pkgs.walker
    pkgs.elephant
    launch-walker
    restart-walker
  ];

  # Remove some desktop entries
  xdg.desktopEntries = {
    "gtk3-demo" = {
      name = "gtk3-demo";
      noDisplay = true;
    };
    "gtk3-icon-browser" = {
      name = "gtk3-icon-browser";
      noDisplay = true;
    };
    "gtk3-widget-factory" = {
      name = "gtk3-widget-factory";
      noDisplay = true;
    };
    "org.gtk.Demo4" = {
      name = "org.gtk.Demo4";
      noDisplay = true;
    };
    "org.gtk.gtk4.NodeEditor" = {
      name = "org.gtk.gtk4.NodeEditor";
      noDisplay = true;
    };
    "org.gtk.PrintEditor4" = {
      name = "org.gtk.PrintEditor4";
      noDisplay = true;
    };
    "org.gtk.Shaper" = {
      name = "org.gtk.Shaper";
      noDisplay = true;
    };
    "org.gtk.WidgetFactory4" = {
      name = "org.gtk.WidgetFactory4";
      noDisplay = true;
    };
  };

  xdg.configFile."walker/config.toml".source = ./config.toml;
  xdg.configFile."walker/themes/kanso/layout.xml".source = ./kanso-layout.xml;

  xdg.configFile."elephant/calc.toml".source = ./elephant/calc.toml;
  xdg.configFile."elephant/desktopapplications.toml".source = ./elephant/desktopapplications.toml;
  xdg.configFile."elephant/symbols.toml".source = ./elephant/symbols.toml;
  xdg.configFile."elephant/websearch.toml".source = ./elephant/websearch.toml;

  systemd.user.services.walker = {
    Unit = {
      Description = "Walker - Application Runner";
      ConditionEnvironment = "WAYLAND_DISPLAY";
      After = [
        "graphical-session.target"
        "elephant.service"
      ];
      Requires = ["elephant.service"];
      PartOf = ["graphical-session.target"];
    };
    Service = {
      Environment = "GSK_RENDERER=cairo";
      ExecStart = "${pkgs.walker}/bin/walker --gapplication-service";
      Restart = "always";
      RestartSec = 2;
    };
    Install = {
      WantedBy = ["graphical-session.target"];
    };
  };
}
