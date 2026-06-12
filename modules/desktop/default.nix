{...}:
{
  imports = [
    ./hyprland.nix
    ./displaymanager.nix
    ./fonts.nix
  ];

  # localsend uses this port for LAN discovery and file transfer
  networking.firewall = {
    allowedTCPPorts = [ 53317 ];
    allowedUDPPorts = [ 53317 ];
  };
}
