# Programs

Programs are added declaratively through feature modules — there is no central `home.packages` or `environment.systemPackages` list to edit.

## System-wide program

Add it to a NixOS feature module under `flake-modules/nixos/`:

```nix
{...}: {
  flake.modules.nixos.desktop-my-program = {pkgs, ...}: {
    environment.systemPackages = [pkgs.my-program];
  };
}
```

Then reference `desktop-my-program` from the `desktop` bundle or a host module.

## User-level program

Add it to a home-manager feature module under `flake-modules/home/`:

```nix
{...}: {
  flake.modules.homeManager.home-my-program = {pkgs, ...}: {
    home.packages = [pkgs.my-program];
  };
}
```

Then reference `home-my-program` from `home-desktop` or `home-server`.

## Declarative program config

Prefer the `programs.*` options where available (`programs.git`, `programs.zsh`, `programs.chromium`, `programs.btop`, `programs.steam`, …); they manage dotfiles and systemd units for you.
