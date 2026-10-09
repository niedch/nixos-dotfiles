{
  pkgs,
  lib,
  config,
  inputs,
  osConfig,
  ...
}: let
  # Hyprland's own flake package — the exact compositor the running session
  # uses (nixarchy sets programs.hyprland.package to this, not nixpkgs').
  # Its bin/ holds hyprctl, which omarchy-restart-shell needs to relaunch the
  # shell through Hyprland.
  hyprland = inputs.nixarchy.inputs.hyprland.packages.${pkgs.system}.hyprland;

  # The canonical OMARCHY_PATH: nixarchy's generated "tree" mirror, not the raw
  # package's share/omarchy. Pointing omarchy-restart-shell at the raw package
  # made it target the wrong tree during activation, so it failed to kill the
  # running shell and hit "already running".
  omarchyPath = osConfig.programs.nixarchy.tree or "${config.programs.nixarchy.package}/share/omarchy";

  # Omarchy's scripts are unwrapped, so their runtime binaries — quickshell,
  # qs, jq — are NOT in the package's bin/. In the session they come from
  # /run/current-system/sw/bin via systemPackages, but the activation PATH is
  # minimal, so omarchy-restart-shell couldn't find them: its kill and
  # readiness checks silently no-oped ("already running" → "did not become
  # ready"). Put them (and hyprctl) on PATH explicitly.
  omarchyBinPath = lib.makeBinPath (
    [config.programs.nixarchy.package hyprland]
    ++ (osConfig.programs.nixarchy.package.passthru.runtimeDeps or [])
  );

  # One entry per theme, keyed by the theme slug (must match the dir name
  # Omarchy uses, e.g. ~/.local/state/omarchy/current/theme.name).
  #   source     = where the theme itself is fetched from (git).
  #   wallpapers = attrset of filename -> { url; hash; } of extra wallpapers
  #                to download and ADD to the theme's background rotation
  #                (they land in ~/.config/omarchy/backgrounds/<slug>/).
  themes = {
    koyanagi = {
      source = pkgs.fetchFromGitHub {
        owner = "niedch";
        repo = "omarchy-koyanagi-theme";
        rev = "63addbeb6df20cdee9cb007eec8fe81c95e3834f";
        sha256 = "sha256-QP3CGQ8lu4LMocyfrkFa+PYQSpNiqCOZVbcKRV/GVgo=";
      };
      wallpapers = {
        "malboro-car.jpg" = {
          url = "https://w.wallhaven.cc/full/d8/wallhaven-d8vvlo.png";
          hash = "sha256-rdf7N8ux2R2cQaxDfhyXOGCstDDFy3wzBfWDci99M4k=";
        };
        "banff.jpg" = {
          url = "https://w.wallhaven.cc/full/e8/wallhaven-e8v1x8.jpg";
          hash = "sha256-GIUE/tvBE/Ei43T6kOPYFBsWy74sqs2TBAZs9NJNveM=";
        };
        "icefields.jpg" = {
          url = "https://w.wallhaven.cc/full/po/wallhaven-pomx99.jpg";
          hash = "sha256-FFdtO9YODPpVoOh5tzlurRLmCDiNoNHyBe6apDOGgiA=";
        };
      };
    };

    # To add another theme later, add a sibling entry:
    # mytheme = {
    #   source = pkgs.fetchFromGitHub { ... };
    #   wallpapers = { "foo.jpg" = { url = "..."; hash = "..."; }; };
    # };
  };

  # Derive xdg.configFile entries from `themes`:
  #   omarchy/themes/<slug>  -> theme source (recursive)
  themeConfigFiles =
    lib.mapAttrs' (
      themeName: theme:
        lib.nameValuePair "omarchy/themes/${themeName}" {
          source = theme.source;
          recursive = true;
        }
    )
    themes;

  #   omarchy/backgrounds/<slug>/<file> -> fetched wallpaper
  wallpaperFiles =
    lib.concatMapAttrs (
      themeName: theme:
        lib.mapAttrs' (
          filename: img:
            lib.nameValuePair "omarchy/backgrounds/${themeName}/${filename}" {
              source = pkgs.fetchurl {inherit (img) url hash;};
            }
        )
        theme.wallpapers
    )
    themes;
in {
  xdg.configFile = themeConfigFiles // wallpaperFiles;

  # Re-apply the active theme after every rebuild so Nix-controlled theme
  # changes (e.g. the Ghostty background opacity) reach the staging dir at
  # ~/.local/state/omarchy/current/theme without a manual `omarchy theme refresh`.
  home.activation.omarchyShellRestart = lib.hm.dag.entryAfter ["writeBoundary"] ''
    export PATH="${omarchyBinPath}:$PATH"
    export OMARCHY_PATH="${omarchyPath}"
    omarchy restart shell
  '';
}
