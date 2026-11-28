{...}: {
  flake.modules.homeManager.home-media-nautilus = {pkgs, ...}: {
    home.packages = with pkgs; [
      nautilus
      yaru-theme
    ];

    xdg.mime.enable = true;
    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "inode/directory" = "org.gnome.Nautilus.desktop";
      };
    };
  };
}
