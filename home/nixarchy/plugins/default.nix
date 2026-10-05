{ lib, config, ... }: {
  imports = [
    ./omapods.nix
    ./numr.nix
    ./media.nix
    ./workspace-styles.nix
    ./lock.nix
    ./calendar.nix
  ];

  # Declares the bar layout (and thus plugin enablement) for a fresh machine.
  # NOTE: xdg.configFile creates a read-only store symlink, so runtime changes
  # (omarchy bar move, plugin enable/disable, widget settings) will NOT persist.
  # To change the layout, edit ./omapods-shell.json and rebuild.
  xdg.configFile."omarchy/shell.json".source = ./omarchy-shell.json;

  # Re-apply the active theme after every rebuild so Nix-controlled theme
  # changes (e.g. the Ghostty background opacity) reach the staging dir at
  # ~/.local/state/omarchy/current/theme without a manual `omarchy theme refresh`.
  home.activation.omarchyThemeRefresh = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    export PATH="${config.programs.nixarchy.package}/bin:$PATH"
    export OMARCHY_PATH="${config.programs.nixarchy.package}/share/omarchy"
    omarchy theme refresh || true
  '';
}
