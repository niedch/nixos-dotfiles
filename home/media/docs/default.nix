{...}: {
  xdg.mime.enable = true;
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      # documents
      "application/pdf" = "org.gnome.Evince.desktop";
    };
  };
}
