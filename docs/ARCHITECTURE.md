# Architecture

This repository follows the [dendritic pattern](https://github.com/mightyiam/dendritic): a *top-level configuration* (flake-parts) declares and evaluates lower-level configurations (NixOS, home-manager). Every `.nix` file except entry points is a top-level module of that configuration.

## Principles

1. **Every file is a top-level module.** Each `.nix` file under `flake-modules/` is a flake-parts module, auto-imported by `import-tree`.
2. **Path names the feature.** Files can be moved/renamed freely; the feature name is set explicitly via `flake.modules.<class>.<name>`.
3. **Lower-level modules are option values.** NixOS and home-manager modules are stored under `flake.modules.nixos.*` and `flake.modules.homeManager.*` as `lib.types.deferredModule` values, which merge by value.
4. **Hosts compose features by name.** A host lists the feature names it wants; it does not trace through `imports`.

## Top-level configuration

`flake.nix` uses `flake-parts.lib.mkFlake` and imports:

- `flake-modules/_lib` — declares `options.flake.modules` and injects `mkNixosSystem` via `_module.args`.
- `import-tree ./flake-modules` — auto-imports every other module file (ignoring `/_` paths and `*.pkg.nix` files).

```nix
# flake.nix (abridged)
outputs = inputs:
  inputs.flake-parts.lib.mkFlake {inherit inputs;} {
    systems = ["x86_64-linux"];
    imports = [
      ./flake-modules/_lib
      (inputs.import-tree.filterNot (inputs.nixpkgs.lib.hasSuffix ".pkg.nix") ./flake-modules)
    ];
    _module.args.rootPath = ./.;
  };
```

## Module classes

`_lib/default.nix` declares the module-class tree:

```nix
options.flake.modules = lib.mkOption {
  type = lib.types.lazyAttrsOf (lib.types.lazyAttrsOf lib.types.deferredModule);
  default = {};
};
```

Feature modules contribute to it:

```nix
# flake-modules/nixos/desktop/hyprland.nix
{...}: {
  flake.modules.nixos.desktop-hyprland = {pkgs, ...}: {
    programs.hyprland.enable = true;
    # ...
  };
}
```

```nix
# flake-modules/home/git/default.nix
{...}: {
  flake.modules.homeManager.home-git = {pkgs, lib, ...}: {
    programs.git.enable = true;
    # ...
  };
}
```

Bundles combine child features under one name:

```nix
# flake-modules/nixos/desktop/default.nix
{config, lib, ...}: {
  flake.modules.nixos.desktop = {pkgs, ...}: {
    imports = with config.flake.modules.nixos; [
      desktop-dux desktop-hyprland desktop-fonts # ...
    ];
    services.pipewire.enable = true;
    # ...
  };
}
```

## Host composition

A host module builds a `nixosConfigurations` entry via the `mkNixosSystem` helper:

```nix
# flake-modules/hosts/desktop.nix
{config, mkNixosSystem, ...}: {
  flake.nixosConfigurations.desktop = mkNixosSystem {
    modules = [
      config.flake.modules.nixos.common
      config.flake.modules.nixos.common-syncthing
      config.flake.modules.nixos.desktop
      ../../hosts/desktop      # host-local hardware config
    ];
    home = config.flake.modules.homeManager.home-desktop;
  };
}
```

`mkNixosSystem` (in `_lib`) appends the sops-nix and home-manager NixOS modules, passes `inputs`/`rootPath` via `specialArgs`, and embeds home-manager as a NixOS module for user `nic`.

## Outputs

- `nixosConfigurations.{desktop,laptop,dobby,raspberry-pi}` — the four hosts.
- `deploy` — deploy-rs nodes (see `flake-modules/outputs/deploy.nix`).
- `packages.x86_64-linux.{mux-session,opencode}` — convenience wrappers.
- `devShells.x86_64-linux.default` — the dev shell used by `.envrc`.
- `checks.x86_64-linux.*` — evaluation checks, derived automatically from `nixosConfigurations`.

## Conventions

- `_`-prefixed paths and directories are ignored by import-tree (helpers, assets, widgets, templates).
- `*.pkg.nix` files are package functions (not modules) and are excluded from auto-import.
- `hosts/<host>/` holds host-local, non-feature data (hardware configuration, power tuning).
