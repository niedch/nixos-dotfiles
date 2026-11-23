{ inputs, pkgs, lib, ... }: {
  imports = [
    inputs.dms.homeModules.dank-material-shell
    inputs.dux-calendar.homeModules.dank-calendar
    inputs.dms-plugin-registry.homeModules.default
    ./calendar.nix
    ./wallpapers.nix
    ./airpods.nix
  ];

  services.librepods.enable = true;

  home.sessionVariables.DMS_HIDE_TRAYIDS = "librepods,openpods";

  programs.dank-calendar = {
    enable = true;
    systemd = {
      enable = true;
      restartIfChanged = true;
    };
  };

  home.pointerCursor = {
    enable = true;
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 12;
  };

  xdg.configFile."dms/koyagani-theme.json".source = ./koyagani-theme.json;

  programs.dank-material-shell = {
    enable = true;
    managePluginSettings = true;

    settings = lib.importJSON ./settings.json;

    plugins = {
      dockerManager.enable = true;
      dcalUpcoming.enable = true;
      librepods.enable = true;
    };

    session = {
      isLightMode = false;
      wallpaperPath = "/home/nic/.config/dms/wallpapers/malboro-car.jpg";
      wallpaperCyclingFolderPath = "/home/nic/.config/dms/wallpapers";
      # Add any other session state settings here
    };

    clipboardSettings = {
      maxHistory = 25;
      maxEntrySize = 5242880;
      autoClearDays = 1;
      clearAtStartup = true;
      disabled = false;
      disableHistory = false;
      disablePersist = true;
    };
  };
}
