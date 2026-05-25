{ config, pkgs, ... }: 

{
	home.username = "nic";
	home.homeDirectory = "/home/nic";
	home.stateVersion = "25.11";
	programs.home-manager.enable = true;

	home.packages = with pkgs; [
		ghostty
		waybar
		rofi-wayland
	]
}
