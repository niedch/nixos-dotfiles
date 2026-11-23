{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.dms.nixosModules.dank-material-shell
    inputs.dms-plugin-registry.nixosModules.default
    inputs.dux-greeter.nixosModules.default
  ];

  environment.systemPackages = [
    pkgs.adw-gtk3
  ];

  programs.librepods.enable = true;

  systemd.user.services.dms = {
    environment = {
      DMS_HIDE_TRAYIDS = "librepods,openpods";
    };
  };

  programs.dank-material-shell = {
    enable = true;
    systemd = {
      enable = true; # Systemd service for auto-start
      restartIfChanged = true; # Auto-restart dms.service when dank-material-shell changes
    };

    plugins = {
      dockerManager.enable = true;
    };
  };

  programs.dms-greeter = {
    enable = true;
    compositor.name = "hyprland";
    configFiles = [
      "/home/nic/.config/dms/settings.json"
      "/home/nic/.local/state/dms/session.json"
      "/home/nic/.cache/dms/dms-colors.json"
    ];
  };
}
