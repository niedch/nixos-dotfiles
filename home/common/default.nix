{ config, pkgs, ... }: 

{
	imports = [
		../hyprland
		../nvim
		../zsh
		../mise
	];

	home.username = "nic";
	home.homeDirectory = "/home/nic";
	home.stateVersion = "25.11";

	programs.home-manager.enable = true;

	home.packages = with pkgs; [
		git
		waybar
		wofi
		dunst
		wl-clipboard
		ghostty
		opencode
	];

}
