{ pkgs, inputs, lib, ... }:

{
	wayland.windowManager.hyprland = {
		enable = true;
		package = inputs.hyprland.packages.${pkgs.system}.hyprland;
		systemd.enable = false;
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
		theme.name = "Adwaita-dark";
		cursorTheme = {
			package = pkgs.bibata-cursors;
			name = "Bibata-Modern-Classic";
			size = 12;
		};
	};

	dconf = {
		enable = true;
		settings = {
			"org/gnome/desktop/interface" = {
				color-scheme = "prefer-dark";
				gtk-theme = "Adwaita-dark";
			};
		};
	};

	home.activation.setGnomeIconTheme = lib.hm.dag.entryAfter [ "setupThemes" ] ''
		ICON_THEME=$(cat "$HOME/.themes-src/current/icons.theme" 2>/dev/null || echo "Adwaita")
		gsettings set org.gnome.desktop.interface icon-theme "$ICON_THEME"
	'';

	xdg.configFile."hypr/hyprland.lua".source = ./hyprland.lua;
	xdg.configFile."hypr/hypridle.conf".source = ./hypridle.conf;
	xdg.configFile."hypr/hyprsunset.conf".source = ./hyprsunset.conf;

	home.packages = with pkgs; [
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
