{ pkgs, inputs, ... }:

{
	wayland.windowManager.hyprland = {
		enable = true;
		package = inputs.hyprland.packages.${pkgs.system}.hyprland;
		systemd.enable = true;
	};

	gtk = {
		enable = true;
		cursorTheme = {
			package = pkgs.bibata-cursors;
			name = "Bibata-Modern-Classic";
			size = 24;
		};
	};

	xdg.configFile."hypr/hyprland.lua".source = ./hyprland.lua;

	home.packages = with pkgs; [
		waybar
		rofi
		dunst
		wl-clipboard
		bibata-cursors
  ];
}
