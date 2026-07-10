{pkgs, ...}: {
  systemd.user.services.mako = {
    Unit = {
      Description = "Mako - Notification Daemon";
      ConditionEnvironment = "WAYLAND_DISPLAY";
      After = ["hyprland-session.target"];
      PartOf = ["hyprland-session.target"];
    };
    Service = {
      ExecStart = "${pkgs.mako}/bin/mako";
      Restart = "always";
      RestartSec = 2;
    };
    Install = {
      WantedBy = ["hyprland-session.target"];
    };
  };

  systemd.user.services.swaybg = {
    Unit = {
      Description = "SwayBG - Wallpaper";
      ConditionEnvironment = "WAYLAND_DISPLAY";
      After = ["hyprland-session.target"];
      PartOf = ["hyprland-session.target"];
    };
    Service = {
      ExecStart = "${pkgs.swaybg}/bin/swaybg -i %h/.local/share/themes/current-background -m fill";
      Restart = "always";
      RestartSec = 2;
    };
    Install = {
      WantedBy = ["hyprland-session.target"];
    };
  };

  systemd.user.services.hyprsunset = {
    Unit = {
      Description = "Hyprsunset - Blue light filter";
      ConditionEnvironment = "WAYLAND_DISPLAY";
      After = ["hyprland-session.target"];
      PartOf = ["hyprland-session.target"];
    };
    Service = {
      ExecStart = "${pkgs.hyprsunset}/bin/hyprsunset";
      Restart = "on-failure";
      RestartSec = 2;
    };
    Install = {
      WantedBy = ["hyprland-session.target"];
    };
  };

  systemd.user.services.polkit-gnome = {
    Unit = {
      Description = "PolicyKit Authentication Agent";
    };
    Install = {
      WantedBy = ["hyprland-session.target"];
    };
    Service = {
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };
}
