{ config, pkgs, inputs, ... }:

{
	programs.hyprland = {
		enable = true;
		package = inputs.hyprland.packages.${pkgs.system}.hyprland;
		portalPackage = inputs.hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland;
	};

	environment.sessionVariables = {
		NIXOS_OZONE_WL = "1";
		WLR_NO_HARDWARE_CURSORS = "1";
	};

	security.polkit.enable = true;
	hardware.opengl.enable = true;
}
