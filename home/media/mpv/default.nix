{ pkgs, ... }: {
  home.packages = with pkgs; [
    mpv
    qimgv
  ];

  xdg.configFile = {
    "mpv/mpv.conf".source = ./config/mpv.conf;
    "mpv/input.conf".source = ./config/input.conf;
    "mpv/script-opts/osc.conf".source = ./config/script-opts/osc.conf;
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      # images
      "image/jpeg" = "qimgv.desktop";
      "image/png" = "qimgv.desktop";
      "image/gif" = "qimgv.desktop";
      "image/bmp" = "qimgv.desktop";
      "image/webp" = "qimgv.desktop";

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
