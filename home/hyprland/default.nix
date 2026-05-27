{ pkgs, inputs, ... }:

{
	wayland.windowManager.hyprland = {
		enable = true;
		package = inputs.hyprland.packages.${pkgs.system}.hyprland;
		systemd.enable = true;
	};

	systemd.user.services.polkit-gnome = {
		Unit = {
			Description = "PolicyKit Authentication Agent";
		};
		Install = {
			WantedBy = [ "hyprland-session.target" ];
		};
		Service = {
			ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
			Restart = "on-failure";
			RestartSec = 1;
			TimeoutStopSec = 10;
		};
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
	xdg.configFile."hypr/hypridle.conf".source = ./hypridle.conf;
	xdg.configFile."hypr/hyprlock.conf".source = ./hyprlock.conf;
	xdg.configFile."hypr/hyprsunset.conf".source = ./hyprsunset.conf;

	home.packages = with pkgs; [
		waybar
		rofi
		mako
		wl-clipboard
		bibata-cursors
		swaybg
		hypridle
		hyprpicker
		playerctl
		brightnessctl
		grim
		slurp
		nautilus
		polkit_gnome
		libnotify
		jq
	];
}
