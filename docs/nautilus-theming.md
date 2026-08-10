# Nautilus & GTK Theming

Nautilus (and other GNOME/libadwaita apps) picks up theming from **`nix-omarchy-theme`**, which handles everything via `home.activation.setupThemes` and the `theme-switcher` script.

## What `nix-omarchy-theme` does

On `home-manager switch` and live `theme-switcher`:

| Setting | Source | Mechanism |
|---------|--------|-----------|
| `gtk-theme` | `gtk.theme` file in theme, or `Adwaita`/`Adwaita-dark` | dconf + `settings.ini` |
| `icon-theme` | `icons.theme` file in theme, or `gtk.iconTheme` Nix option | dconf + `settings.ini` |
| `color-scheme` | `prefer-light`/`prefer-dark` based on `light.mode` | dconf only |
| `cursor-theme` | `gtk.cursorTheme.name` Nix option | dconf + `settings.ini` |
| GTK CSS overrides | `gtk.css` template with theme colors | Symlinked to `~/.config/gtk-3.0/` and `~/.config/gtk-4.0/` |

## How it propagates to apps

- **dconf/gsettings** — set by the `01_apply_gtk` hook on every theme switch. Picked up by GNOME/libadwaita apps via the settings portal or directly.
- **`~/.config/gtk-3.0/settings.ini` and `~/.config/gtk-4.0/settings.ini`** — symlinked to `~/.local/share/themes/current/settings-*.ini`. GTK reads these as fallback.
- **`ADW_DISABLE_PORTAL=1`** — set in `home/hyprland/conf/env.lua`. Required on Hyprland because `xdg-desktop-portal-hyprland` doesn't implement `org.freedesktop.portal.Settings`. Without it, libadwaita apps fail to read `color-scheme` from the portal and may fall back to light mode.

## Warning: GTK_THEME env var

Do **not** set the `GTK_THEME` environment variable. libadwaita explicitly checks for it and, if set, **skips loading its own modern stylesheet** entirely. This causes Nautilus and other libadwaita apps to render with a plain GTK fallback theme instead — the "old" look with no libadwaita widget styling.

Setting the theme via gsettings/dconf (as the `01_apply_gtk` hook does) is the correct approach and preserves the full libadwaita look.

## Theme ↔ icon mapping

Each Omarchy theme ships an `icons.theme` file containing the icon theme name:

| Theme | Icon theme |
|-------|-----------|
| kanso | Yaru-prussiangreen |
| catppuccin | Yaru-purple |
| tokyo-night | Yaru-magenta |
| nord | Yaru-blue |
| (default fallback) | Adwaita |
