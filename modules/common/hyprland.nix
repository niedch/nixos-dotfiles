{ config, pkgs, inputs, ... }:

{
	programs.hyprland = {
		enable = true;
		package = inputs.hyprland.packages.${pkgs.system}.hyprland;
		portalPackage = inputs.hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland;
	};

	environment.sessionVariables = {
		NIXOS_OZONE_WL = "1";
		XCURSOR_THEME = "Bibata-Modern-Classic";
		XCURSOR_SIZE = "24";
		GDK_BACKEND = "wayland,x11,*";
		QT_QPA_PLATFORM = "wayland;xcb";
		MOZ_ENABLE_WAYLAND = "1";
		XDG_CURRENT_DESKTOP = "Hyprland";
		XDG_SESSION_DESKTOP = "Hyprland";
		XDG_SESSION_TYPE = "wayland";
	};

	xdg.portal = {
		enable = true;
		extraPortals = with pkgs; [
			xdg-desktop-portal-gtk
		];
	};

	security.polkit.enable = true;
	hardware.graphics.enable = true;

	boot.kernelParams = [ "video=1920x1080@60" ];
	boot.kernelModules = [ "virtio_gpu" ];
}
