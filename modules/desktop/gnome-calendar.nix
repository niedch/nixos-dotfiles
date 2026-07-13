{pkgs, ...}: let
  goa = pkgs.gnome-online-accounts.overrideAttrs (old: {
    buildInputs = old.buildInputs ++ [pkgs.webkitgtk_6_0];
  });
in {
  environment.systemPackages = [
    pkgs.gnome-calendar
    goa
    pkgs.gnome-online-accounts-gtk
  ];

  services.dbus.packages = [goa];
}
