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

	home.activation.setGnomeIconTheme = lib.hm.dag.entryAfter [ "setupThemes" ] ''
		ICON_THEME=$(cat "$HOME/.themes-src/current/icons.theme" 2>/dev/null || echo "Adwaita")
		${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/icon-theme "'$ICON_THEME'"

		for dir in "$HOME/.config/gtk-3.0" "$HOME/.config/gtk-4.0"; do
			mkdir -p "$dir"
			rm -f "$dir/settings.ini" "$dir/gtk.css" 2>/dev/null || true
			ln -sfn "$HOME/.themes-src/current/settings.ini" "$dir/settings.ini" 2>/dev/null || true
			ln -sfn "$HOME/.themes-src/current/gtk.css" "$dir/gtk.css" 2>/dev/null || true
		done
	'';

	xdg.configFile."hypr/hyprland.lua".source = ./hyprland.lua;
	xdg.configFile."hypr/hypridle.conf".source = ./hypridle.conf;
	xdg.configFile."hypr/hyprsunset.conf".source = ./hyprsunset.conf;

	home.packages = with pkgs; [
		mako
		wl-clipboard
		bibata-cursors
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
