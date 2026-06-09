# Nautilus Theming

Nautilus (and other GNOME/GTK apps) picks up the theme and icon pack via **dconf/gsettings**.

## How it works

Two paths keep the icon theme in sync with Omarchy's current theme:

### 1. `home-manager switch` — `home/hyprland/default.nix`

- `gtk.theme.name = "Adwaita-dark"` — writes `gtk-theme-name` to `~/.config/gtk-3.0/settings.ini` and `~/.config/gtk-4.0/settings.ini` for GTK3/4 apps
- `dconf.settings."org/gnome/desktop/interface"` — declaratively sets `color-scheme` and `gtk-theme` in the dconf database
- `home.activation.setGnomeIconTheme` — reads `~/.themes-src/current/icons.theme` and runs `gsettings set org.gnome.desktop.interface icon-theme` on every rebuild

### 2. Live theme switch — `nix-omarchy-theme-manager/flake.nix`

The `theme-switcher` script (aliased to `ts`) now updates gsettings after switching:

- `icon-theme` → read from `~/.themes-src/current/icons.theme`
- `gtk-theme` → `"Adwaita-dark"`
- `color-scheme` → `"prefer-dark"`

## Files changed

| File | Change |
|------|--------|
| `home/hyprland/default.nix` | Added `gtk.theme.name`, `dconf` block, `home.activation.setGnomeIconTheme` |
| `nix-omarchy-theme-manager/flake.nix` | Added gsettings commands to `theme-switcher` script |

## Theme ↔ icon mapping

Each Omarchy theme ships an `icons.theme` file containing the icon theme name:

| Theme | Icon theme |
|-------|-----------|
| kanso | Yaru-prussiangreen |
| catppuccin | Yaru-purple |
| tokyo-night | Yaru-magenta |
| nord | Yaru-blue |
| (default fallback) | Adwaita |
