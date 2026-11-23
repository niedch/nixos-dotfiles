{ inputs, ... }: {
  imports = [
    inputs.dms.nixosModules.dank-material-shell
    inputs.dux-greeter.nixosModules.default
  ];

  programs.librepods.enable = true;

  programs.dank-material-shell = {
    enable = true;
    systemd = {
      enable = true; # Systemd service for auto-start
      restartIfChanged = true; # Auto-restart dms.service when dank-material-shell changes
    };
  };

  programs.dms-greeter = {
    enable = true;
    compositor.name = "hyprland";  # Or "hyprland" or "sway"
  };
}
