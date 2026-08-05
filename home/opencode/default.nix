{pkgs, inputs, ...}: let
  opencode = import ./package.nix {inherit pkgs;};
in {
  imports = [
    inputs.opencode-waybar-status.homeModules.default
  ];

  programs.opencode-waybar-status = {
    enable = true;
    package = inputs.opencode-waybar-status.packages.${pkgs.system}.default;
  };

  home.packages = with pkgs; [
    opencode
    jq
  ];
}
