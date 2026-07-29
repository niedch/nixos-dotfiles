{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./power.nix
  ];

  # Bootloader.
  boot.loader.limine = {
    enable = true;
  };
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.

  networking.networkmanager.enable = true;
  networking.wireless.enable = true;

  hardware.bluetooth.enable = true;

  # Legacy driver for Quadro P2000 Mobile (Pascal) — dropped from production 595.x
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
  hardware.nvidia-container-toolkit.enable = true;

  # btop needs this for Intel GPU monitoring (perf_event_open on i915 PMU counters)
  boot.kernel.sysctl."kernel.perf_event_paranoid" = 0;

  # Set your time zone.
  time.timeZone = "Europe/Vienna";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_AT.UTF-8";
    LC_IDENTIFICATION = "de_AT.UTF-8";
    LC_MEASUREMENT = "de_AT.UTF-8";
    LC_MONETARY = "de_AT.UTF-8";
    LC_NAME = "de_AT.UTF-8";
    LC_NUMERIC = "de_AT.UTF-8";
    LC_PAPER = "de_AT.UTF-8";
    LC_TELEPHONE = "de_AT.UTF-8";
    LC_TIME = "de_AT.UTF-8";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  system.stateVersion = "25.11"; # Did you read the comment?
}
