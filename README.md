# nixos-dotfiles

Multi-host NixOS configuration organized with the [dendritic pattern](https://github.com/mightyiam/dendritic): every `.nix` file (except entry points) is a top-level [flake-parts](https://flake.parts) module, auto-imported, where the path names a feature and hosts compose features by name.

## Hosts

| Host          | Type                 | Hostname  | Bootloader   | Key features                                                                 |
|---------------|----------------------|-----------|--------------|------------------------------------------------------------------------------|
| `desktop`     | Physical             | `desktop` | Limine       | Hyprland + Dux/DMS shell, NVIDIA, Windows dual-boot, Steam, virt-manager     |
| `laptop`      | Dell Precision 5530  | `laptop`  | Limine       | Hyprland + Dux/DMS, NVIDIA (legacy), TLP power tuning                        |
| `dobby`       | Server               | `dobby`   | systemd-boot | Immich, Nixflix, Samba, Gitea, Cockpit, gameserver, Glance dashboard, harmonia cache, GitHub runner |
| `raspberry-pi`| Physical (aarch64)   | `rpi`     | extlinux     | Homebridge, minimal SSH                                                      |

## Usage

```bash
sudo nixos-rebuild switch --flake .#desktop       # Desktop
sudo nixos-rebuild switch --flake .#laptop        # Laptop
sudo nixos-rebuild switch --flake .#dobby         # Server
sudo nixos-rebuild switch --flake .#raspberry-pi  # Raspberry Pi (aarch64)
```

Mise tasks wrap the common workflows (`build`, `switch`, `diff`, `deploy`, `cleanup`, `update`):

```bash
mise run build desktop
mise run switch laptop
mise run deploy dobby
```

## Architecture

```
flake.nix                     # flake-parts entry point (inputs + mkFlake + auto-import)
flake-modules/                # auto-imported flake-parts tree — every file is a module
  _lib/default.nix            #   declares `flake.modules` (deferredModule) + mkNixosSystem
  nixos/                      #   system features
    common/                   #     shared by most hosts (bundle name: `common`)
    desktop/                  #     desktop-only (bundle name: `desktop`)
    server/                   #     server-only + gameserver/ + glance/ + homebridge/
  home/                       #   home-manager features
    desktop.nix               #     `home-desktop` profile bundle
    server.nix                #     `home-server` profile bundle
    git/ zsh/ nvim/ ...       #     per-feature modules (git, zsh, nvim, browser, dux, …)
  hosts/                      #   host composition: nixosConfigurations.<host> = { modules = [...] }
  outputs/                    #   deploy, checks, packages, devShells
hosts/<host>/                 # host-local data (hardware-configuration.nix, power.nix)
secrets/                      # SOPS-encrypted secrets.yaml
docs/                         # documentation
```

### How it works

- `flake.nix` runs `flake-parts.lib.mkFlake` with `import-tree` auto-importing everything under `flake-modules/`. Paths containing `/_` are ignored (helpers/assets), and files ending in `.pkg.nix` (package functions) are excluded from module evaluation.
- `_lib/default.nix` declares the `flake.modules` option (an attrset of `deferredModule`s) and a `mkNixosSystem` host builder that wires up sops-nix + home-manager (embedded as a NixOS module for user `nic`).
- Each feature module contributes a lower-level module under `flake.modules.nixos.<name>` or `flake.modules.homeManager.<name>`. Bundles (e.g. `common`, `desktop`, `home-desktop`) import their child features by name.
- Host modules in `flake-modules/hosts/` compose those features by name and produce `nixosConfigurations.<host>`. They never list file paths for features.

## Adding a feature

### System (NixOS) feature

Create `flake-modules/nixos/desktop/my-feature.nix`:

```nix
{...}: {
  flake.modules.nixos.desktop-my-feature = {pkgs, ...}: {
    environment.systemPackages = [pkgs.my-tool];
  };
}
```

Then add `desktop-my-feature` to the bundle in `flake-modules/nixos/desktop/default.nix` (or to a specific host in `flake-modules/hosts/*.nix`).

### Home-manager feature

Create `flake-modules/home/my-feature/default.nix`:

```nix
{...}: {
  flake.modules.homeManager.home-my-feature = {pkgs, ...}: {
    home.packages = [pkgs.my-tool];
  };
}
```

Then add `home-my-feature` to a profile in `flake-modules/home/desktop.nix` or `flake-modules/home/server.nix`.

## Adding a host

1. Add `hosts/<host>/` with `default.nix` + `hardware-configuration.nix` (see existing hosts).
2. Add `flake-modules/hosts/<host>.nix` composing the features you want (see `flake-modules/hosts/desktop.nix`).
3. Update `flake-modules/outputs/deploy.nix` if the host should be deployable via deploy-rs.
4. Rebuild: `sudo nixos-rebuild switch --flake .#<host>`.

## Secrets

Secrets are encrypted with [SOPS](https://github.com/getsops/sops) using [age](https://age-encryption.org/), stored in `secrets/secrets.yaml` and decrypted at build time by sops-nix. Recipients are configured in `.sops.yaml`.

## Docs

- `docs/ARCHITECTURE.md` — the dendritic pattern in detail.
- `docs/MODULES.md` — module classes and conventions.
- `docs/HOSTS.md` — host composition.
- `docs/harmonia-cache.md` — the self-hosted binary cache.
- `docs/setup-sops.md` / `docs/setup-raspberry-pi.md` — setup guides.
