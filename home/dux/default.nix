{ inputs, pkgs, lib, ... }: {
  imports = [
    inputs.dms.homeModules.dank-material-shell
    inputs.dux-calendar.homeModules.dank-calendar
    inputs.dms-plugin-registry.homeModules.default
    ./calendar.nix
    ./cursor.nix
    ./wallpapers.nix
    ./airpods.nix
  ];

  home.sessionVariables.DMS_HIDE_TRAYIDS = "librepods,openpods";

  xdg.configFile."dms/koyagani-theme.json".source = ./koyagani-theme.json;
  services.librepods.enable = true;

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
