{ pkgs, lib, config, ... }:
let
  src = pkgs.fetchgit {
    name = "omarchy-calendar";
    url = "https://github.com/tmn73/omarchy-calendar.git";
    rev = "1b1a4983bf617485fe223fab6a11f1eb5113d9e0";
    hash = "sha256-SVYIBmMLaY3A5b8WHQ/jUJfZE05kGEAxvPxCYNezIJs=";
  };

  # The iCal sync needs icalendar + recurring-ical-events; tzdata makes
  # zoneinfo (DST-accurate) resolve on NixOS.
  syncEnv = pkgs.python3.withPackages (ps: [
    ps.icalendar
    ps.recurring-ical-events
    ps.tzdata
  ]);
in
{
  programs.nixarchy.plugins.calendar.src = src;

  # The iCal config is a secret, stored in sops as CALENDAR_CONFIG. Its
  # decrypted value is the full calendar-sync.json content, written here to a
  # 0600 file the sync reads.
  sops.secrets.CALENDAR_CONFIG = {
    path = "${config.home.homeDirectory}/.config/omarchy/calendar-sync.json";
    mode = "0600";
  };

  systemd.user.services.omarchy-calendar-sync = {
    Unit = {
      Description = "Sync iCal calendars into the Omarchy calendar widget";
      After = [ "network-online.target" ];
      Wants = [ "network-online.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${syncEnv}/bin/python3 ${src}/sync/omarchy-calendar-sync";
    };
  };

  systemd.user.timers.omarchy-calendar-sync = {
    Unit = {
      Description = "Refresh the Omarchy calendar widget events file";
    };
    Timer = {
      OnCalendar = "*:0/5";
      Persistent = true;
      AccuracySec = "30s";
    };
    Install = {
      WantedBy = [ "timers.target" ];
    };
  };
}
