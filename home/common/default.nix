{ config, pkgs, ... }: 

{
	home.username = "nic";
	home.homeDirectory = "/home/nic";
	home.stateVersion = "25.11";

	programs.home-manager.enable = true;

	home.packages = with pkgs; [
		waybar
		rofi-wayland
		dunst
		wl-clipboard
	];

	wayland.windowManager.hyprland = {
		enable = true;
	};
}
