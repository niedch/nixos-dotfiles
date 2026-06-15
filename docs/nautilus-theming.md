# Nautilus & GTK Theming

Nautilus (and other GNOME/libadwaita apps) picks up theming from **`nix-omarchy-theme`**, which handles everything via `home.activation.setupThemes` and the `theme-switcher` script.

## What `nix-omarchy-theme` does

On `home-manager switch` and live `theme-switcher`:

| Setting | Source | Mechanism |
|---------|--------|-----------|
| `gtk-theme` | `gtk.theme` file in theme, or `Adwaita`/`Adwaita-dark` | dconf + `settings.ini` + `GTK_THEME` env var |
| `icon-theme` | `icons.theme` file in theme, or `gtk.iconTheme` Nix option | dconf + `settings.ini` |
| `color-scheme` | `prefer-light`/`prefer-dark` based on `light.mode` | dconf only |
| `cursor-theme` | `gtk.cursorTheme.name` Nix option | dconf + `settings.ini` |
| GTK CSS overrides | `gtk.css` template with theme colors | Symlinked to `~/.config/gtk-3.0/` and `~/.config/gtk-4.0/` |

## How it propagates to apps

- **dconf/gsettings** — picked up by GNOME apps and Wayland sessions
- **`~/.config/environment.d/theme.conf`** — read by systemd user services on login; sets `GTK_THEME` and `ADW_DISABLE_PORTAL`
- **zsh init** — `theme.conf` is sourced on shell start so terminal-launched apps inherit both variables
- **`GTK_THEME=Name:dark` env var** — forces libadwaita apps (Nautilus) to use the theme
- **`ADW_DISABLE_PORTAL=1`** — required on Hyprland because `xdg-desktop-portal-hyprland` doesn't implement `org.freedesktop.portal.Settings`. Without it, libadwaita apps fail to read `color-scheme` from the portal and fall back to light mode instead of reading dconf

## Theme ↔ icon mapping

Each Omarchy theme ships an `icons.theme` file containing the icon theme name:

| Theme | Icon theme |
|-------|-----------|
| kanso | Yaru-prussiangreen |
| catppuccin | Yaru-purple |
| tokyo-night | Yaru-magenta |
| nord | Yaru-blue |
| (default fallback) | Adwaita |
