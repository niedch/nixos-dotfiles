# Hosts

Hosts compose features by name. Each host is a top-level module in `flake-modules/hosts/` that produces a `nixosConfigurations.<host>` entry via the `mkNixosSystem` helper.

## Current hosts

| flake attribute | hostname | system        | role                        |
|-----------------|----------|---------------|-----------------------------|
| `desktop`       | `desktop`| x86_64-linux  | desktop                     |
| `laptop`        | `laptop` | x86_64-linux  | desktop (Dell Precision)    |
| `dobby`         | `dobby`  | x86_64-linux  | server                      |
| `raspberry-pi`  | `rpi`    | aarch64-linux | minimal server / homebridge |

## Host composition

```nix
# flake-modules/hosts/desktop.nix
{config, mkNixosSystem, ...}: {
  flake.nixosConfigurations.desktop = mkNixosSystem {
    modules = [
      config.flake.modules.nixos.common
      config.flake.modules.nixos.common-syncthing
      config.flake.modules.nixos.desktop
      ../../hosts/desktop        # host-local hardware config
    ];
    home = config.flake.modules.homeManager.home-desktop;
  };
}
```

- `modules` lists NixOS features (by name) plus the host-local `../../hosts/<host>` module (hardware configuration, power tuning).
- `home` references a home-manager profile bundle (`home-desktop` or `home-server`).
- `raspberry-pi` deliberately selects individual `common-*` features rather than the `common` bundle (it omits docker, binfmt, glances, lunix, syncthing).

## Adding a host

1. Create `hosts/<host>/` with `default.nix` + `hardware-configuration.nix` (generate with `nixos-generate-config`).
2. Create `flake-modules/hosts/<host>.nix` composing the features you want.
3. If it should be deployable via deploy-rs, add a node to `flake-modules/outputs/deploy.nix`.
4. Add the host's age key as a recipient in `.sops.yaml` and re-encrypt `secrets/secrets.yaml` (see `docs/setup-sops.md`).
5. Rebuild: `sudo nixos-rebuild switch --flake .#<host>`.
