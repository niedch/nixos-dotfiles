{ config, pkgs, inputs, ... }:

{
	programs.hyprland = {
		enable = true;
		package = inputs.hyprland.packages.${pkgs.system}.hyprland;
		portalPackage = inputs.hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland;
	};

	environment.sessionVariables = {
		NIXOS_OZONE_WL = "1";
	};

	security.polkit.enable = true;
	hardware.graphics.enable = true;

	boot.kernelParams = [ "video=1920x1080@60" ];
	boot.kernelModules = [ "virtio_gpu" ];
}
