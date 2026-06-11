# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  networking.networkmanager.enable = true;
  networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # networking.networkmanager.wifi.backend = "iwd";

  hardware.bluetooth.enable = true;

  # NVIDIA PRIME offload (Optimus)
  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
    modesetting.enable = true;
    nvidiaSettings = true;
    open = false;

    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      sync.enable = false;
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };

    powerManagement.enable = false;
    powerManagement.finegrained = false;
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  boot.kernelParams = [ "nvidia_drm.fbdev=1" ];
  boot.kernelModules = [ "nvidia" "nvidia_drm" "nvidia_modeset" "nvidia_uvm" ];
  boot.blacklistedKernelModules = [ "nouveau" ];

  # NVIDIA env vars for Wayland/Hyprland
  environment.sessionVariables = {
    __NV_PRIME_RENDER_OFFLOAD = "1";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    __VK_LAYER_NV_optimus = "NVIDIA_only";
    LIBVA_DRIVER_NAME = "nvidia";
  };

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
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  system.stateVersion = "25.11"; # Did you read the comment?

  sops.secrets = {
    mock_secret = {};
    example_api_key = {};
    OPENCODE_API_KEY = {
      owner = "nic";
      group = "users";
      mode = "0440";
    };
  };
}
