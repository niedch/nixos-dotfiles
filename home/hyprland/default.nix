{ pkgs, inputs, ... }:

{
	wayland.windowManager.hyprland = {
		enable = true;
		package = inputs.hyprland.packages.${pkgs.system}.hyprland;
		systemd.enable = true;
	};

	xdg.configFile."hypr/hyprland.lua".source = ./hyprland.lua;

	home.packages = with pkgs; [
		waybar
		rofi
		dunst
		wl-clipboard
  ];
}
