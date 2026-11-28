{...}: {
  flake.modules.nixos.desktop-proton = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      proton-vpn
      proton-pass
    ];
  };
}
