{ inputs, ... }: {
  imports = [
    inputs.dms.nixosModules.dank-material-shell
    inputs.dms-plugin-registry.nixosModules.default
  ];


  programs.librepods.enable = true;

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
}
