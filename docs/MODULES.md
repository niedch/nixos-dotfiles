# Modules

This repo follows the [dendritic pattern](https://github.com/mightyiam/dendritic): every `.nix` file under `flake-modules/` is a top-level flake-parts module, auto-imported. Modules are grouped by *class*.

## Module classes

Lower-level modules are stored as `deferredModule` option values under two classes:

- `flake.modules.nixos.<name>` — NixOS (system) modules.
- `flake.modules.homeManager.<name>` — home-manager (user) modules.

Each feature module is a top-level flake-parts module that sets one of these:

```nix
# flake-modules/nixos/desktop/fonts.nix
{...}: {
  flake.modules.nixos.desktop-fonts = {pkgs, ...}: {
    fonts.packages = [pkgs.nerd-fonts.jetbrains-mono];
  };
}
```

## Bundles

A bundle is a feature whose only job is to import other features by name (and optionally add shared config):

```nix
# flake-modules/nixos/desktop/default.nix
{config, ...}: {
  flake.modules.nixos.desktop = {pkgs, ...}: {
    imports = with config.flake.modules.nixos; [
      desktop-dux
      desktop-hyprland
      # ...
    ];
    services.pipewire.enable = true;
  };
}
```

## Naming

- System features: `<group>-<name>` under `flake.modules.nixos` (e.g. `desktop-hyprland`, `server-immich`, `common-docker`).
- Home features: `home-<name>` under `flake.modules.homeManager` (e.g. `home-git`, `home-nvim`, `home-media-video`).

## Auto-import & exclusions

`import-tree` auto-imports every `.nix` file under `flake-modules/`, except:

- paths containing `/_` (helpers, assets, templates — e.g. `glance/_widgets/`, `glance/_templates/`)
- files ending in `.pkg.nix` (package functions — e.g. `mux-session.pkg.nix`, `opencode.pkg.nix`)

`flake-modules/_lib` is imported explicitly in `flake.nix`; it declares the `flake.modules` option and the `mkNixosSystem` host builder.

## Adding a module

1. Create the file (a feature or a bundle) under the appropriate `flake-modules/` directory.
2. Reference it from a bundle or a host module by name. No manual `imports` of file paths is needed.
