{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    proton-vpn
    proton-pass
  ];
}
