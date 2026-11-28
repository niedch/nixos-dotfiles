{...}: {
  flake.modules.nixos.desktop-fonts = {pkgs, ...}: {
    fonts.packages = with pkgs; [
      nerd-fonts.jetbrains-mono
    ];
  };
}
