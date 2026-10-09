{
  pkgs,
  lib,
  ...
}: {
  programs.nixarchy.plugins.workspace-styles.src = pkgs.fetchgit {
    name = "omarchy-workspace-styles";
    url = "https://github.com/jgarza9788/workspace-styles.git";
    rev = "d86e10fad14eb96095b8d773ccbf6419bf709423";
    hash = "sha256-DXDe2EOddGvD0fOpdlWplTkmWlDIYI1iyeAhqnWQHRw=";
  };
}
