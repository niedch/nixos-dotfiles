hl.env("XCURSOR_THEME", "Bibata-Modern-Classic")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_THEME", "Bibata-Modern-Classic")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("GDK_BACKEND", "wayland,x11,*")
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "wayland")
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")

local gtk_theme_file = os.getenv("HOME") .. "/.themes-src/current/gtk.theme"
local f = io.open(gtk_theme_file, "r")
if f then
  local gtk_theme = f:read("*l")
  f:close()
  local light_file = io.open(os.getenv("HOME") .. "/.themes-src/current/light.mode", "r")
  if light_file then
    light_file:close()
    hl.env("GTK_THEME", gtk_theme)
  else
    if not gtk_theme:match("%-dark$") then
      gtk_theme = gtk_theme .. ":dark"
    end
    hl.env("GTK_THEME", gtk_theme)
  end
else
  hl.env("GTK_THEME", "Adwaita:dark")
end

