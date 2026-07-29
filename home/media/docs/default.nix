{ pkgs, ... }: {
  home.packages = with pkgs; [
    zathura
  ];

  xdg.mime.enable = true;
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      # videos
      "video/mp4" = "mpv.desktop";
      "video/mpeg" = "mpv.desktop";
      "video/x-matroska" = "mpv.desktop";
      "video/webm" = "mpv.desktop";
      "video/x-msvideo" = "mpv.desktop";
      "video/quicktime" = "mpv.desktop";
      "video/x-flv" = "mpv.desktop";
      "video/ogg" = "mpv.desktop";
      "video/3gpp" = "mpv.desktop";
      "video/avi" = "mpv.desktop";
    };
  };
}
