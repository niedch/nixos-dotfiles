{pkgs, ...}: let
  goa = pkgs.gnome-online-accounts.overrideAttrs (old: {
    buildInputs = old.buildInputs ++ [pkgs.webkitgtk_6_0];
  });

  evolution-dark = pkgs.symlinkJoin {
    name = "evolution";
    paths = [pkgs.evolution];
    nativeBuildInputs = [pkgs.makeBinaryWrapper];
    postBuild = ''
      wrapProgram $out/bin/evolution --unset GTK_THEME
    '';
  };
in {
  environment.systemPackages = [
    pkgs.gnome-calendar
    goa
    pkgs.gnome-online-accounts-gtk
    evolution-dark
  ];

  services.dbus.packages = [goa];

  services.gnome = {
    evolution-data-server.enable = true;
    gnome-keyring.enable = true;
  };
}
