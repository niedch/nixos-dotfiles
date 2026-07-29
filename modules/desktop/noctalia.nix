{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.nixosDotfiles.noctalia;
in {
  options.nixosDotfiles.noctalia.enable =
    lib.mkEnableOption "Noctalia shell on Niri as a trial login session";

  # Uses the nixpkgs NixOS niri module (auto-imported in the default module
  # set), which registers the niri wayland-session .desktop for LY and enables
  # gnome-keyring / xdg-desktop-portal. No noctalia NixOS module is needed:
  # noctalia is installed per-user via home-manager and spawned by niri.
  config = lib.mkIf cfg.enable {
    programs.niri.enable = true;
  };
}