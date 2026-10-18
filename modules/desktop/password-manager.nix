{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    proton-pass
    r2modman
  ];
}
