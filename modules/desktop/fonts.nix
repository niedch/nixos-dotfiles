{pkgs, ...}: let
  omarchy-font = pkgs.stdenvNoCC.mkDerivation {
    name = "omarchy-font";
    phases = ["installPhase"];
    src = ./omarchy.ttf;
    installPhase = ''
      mkdir -p $out/share/fonts/truetype
      cp $src $out/share/fonts/truetype/omarchy.ttf
    '';
  };
in {
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    omarchy-font
  ];
}
