{
  ...
}:
{
  imports = [
    ./omapods.nix
    ./numr.nix
    ./media.nix
    ./workspace-styles.nix
    ./lock.nix
    ./calendar.nix
    ./meteobar.nix
    ./syncshell.nix
  ];

  # Declares the bar layout (and thus plugin enablement) for a fresh machine.
  # NOTE: xdg.configFile creates a read-only store symlink, so runtime changes
  # (omarchy bar move, plugin enable/disable, widget settings) will NOT persist.
  # To change the layout, edit ./omapods-shell.json and rebuild.
  xdg.configFile."omarchy/shell.json".source = ./omarchy-shell.json;
}
