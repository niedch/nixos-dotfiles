{...}: {
  flake.modules.homeManager.home-media-docs-pdf = {pkgs, ...}: {
    home.packages = with pkgs; [
      kdePackages.okular
    ];

    xdg.mime.enable = true;
    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "application/pdf" = "org.kde.okular.desktop";
        "application/epub+zip" = "org.kde.okular.desktop";
        "application/postscript" = "org.kde.okular.desktop";
      };
    };
  };
}
