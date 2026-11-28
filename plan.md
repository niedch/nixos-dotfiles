# Dendritic Refactor Plan

> Goal: refactor this multi-host NixOS dotfiles flake from the current
> "host-centric" layout (explicit per-host module lists in `flake.nix`) to the
> **dendritic pattern** (`mightyiam/dendritic`): every Nix file is a top-level
> flake-parts module, auto-imported, where the path names the feature and hosts
> compose features by name.

---

## TODO

- [ ] 1. Add `flake-parts` + `import-tree` inputs; scaffold `mkFlake` entry + module-class options via `lib.types.deferredModule`
- [ ] 2. Establish auto-import + exclusion conventions (`/_` ignored, `*.pkg.nix` for package helpers); relocate non-module files
- [ ] 3. Migrate `modules/common/*` to dendritic feature modules (`flake.modules.nixos.common-*`)
- [ ] 4. Migrate `modules/desktop/*` to dendritic feature modules
- [ ] 5. Migrate `modules/server/*` + `glance/`/`gameserver/`/`homebridge/` subtrees to feature modules (widgets/templates/scripts excluded)
- [ ] 6. Migrate `home/*` to feature modules (`flake.modules.homeManager.*`); isolate `package.nix` helpers
- [ ] 7. Convert hosts to composition modules (`nixosConfigurations.<host>` = feature-name list), preserving `hardware-configuration.nix` + `power.nix`
- [ ] 8. Rewire outputs: `deploy.nix`, `checks`, `packages`, `devShell`; derive host lists from `nixosConfigurations`
- [ ] 9. Update CI workflows + `mise.toml` + `.sops.yaml` references to the derived/renamed host lists
- [ ] 10. Remove dead code (`home/noctalia/`, microvm references, stale doc claims) — KEEP `.sops.yaml` `host_vm` recipient
- [ ] 11. Rewrite `README.md` and `docs/*` for the dendritic architecture
- [ ] 12. Verify: `nix flake check` and host builds pass for all four hosts

---

## Current State (research findings)

### Scope

- 4 hosts: `desktop`, `laptop`, `dobby` (server), `raspberry-pi` (aarch64, hostname `rpi`).
- ~14 flake inputs: `nixpkgs`, `nixos-hardware`, `home-manager`, `sops-nix`,
  `deploy-rs`, `nixflix`, `speedtest-tracker`, `mux-session`, `comd`,
  `nix-lazy-apps`, `dms`, `dms-plugin-registry`, `dux-calendar`, `dux-greeter`.
- Entry point is a plain `flake.nix` with `mkSystem`/`mkHM` helpers and
  `specialArgs = { inherit inputs; }` passed to every host.

### Layout

```
flake.nix            # hosts + inputs + packages + devShell + checks + deploy
deploy.nix           # deploy-rs nodes (dobby, raspberry-pi, desktop, laptop)
mise.toml            # build/switch/diff/deploy/cleanup/update tasks
.sops.yaml           # 6 age recipients (incl. legacy host_vm), 1 creation rule
hosts/<host>/        # hardware-configuration.nix + default.nix (+ laptop/power.nix)
modules/
  common/            # 13 modules: docker, sops, ssh, users, syncthing, glances…
  desktop/           # 11 modules: hyprland, dux, steam, virt-manager, lazy…
  server/            # 13 modules + glance/ + gameserver/ + homebridge/ subtrees
home/                # desktop.nix + server.nix entry points → dux/, media/, tools/, agents/, nvim/…
```

### `modules/common/`

- `default.nix` imports 11 siblings (deliberately excludes `syncthing.nix`).
- `sops.nix` declares `options.sops.enable` (default true) and most secret names;
  its `defaultSopsFile` is a **relative** path `./../../secrets/secrets.yaml`.
- `message-board-client.nix` provides a `post-homepage-message-board` script
  referenced by `nix-gc.nix`, `immich.nix`, `deploy-nodes.nix`, `valheim.nix`.
- `cache-config.nix` pairs with `server/nix-cache.nix` (harmonia `dobby:5000`).
- Duplication: `ssh.nix` vs `server/openssh.nix`; `sops.enable` default declared twice;
  `harmonia-secret` declared in both `sops.nix` and `nix-cache.nix`.
- Latent coupling: `users.nix` assumes `docker` + `greeter` groups; rpi imports
  `users.nix` without `docker.nix`.

### `modules/desktop/`

- `default.nix` is an aggregator (10 siblings) + desktop-wide daemons (PipeWire, dconf, fwupd…).
- `dux.nix` / `lazy.nix` consume flake inputs directly (`inputs.dms`, `inputs.nix-lazy-apps`…).
- `rclone.nix` + `samba-mount.nix` are gated by `config.sops.enable`.
- `steam.nix` reads `config.hardware.nvidia.prime.offload.enable` (never set → always false).

### `modules/server/`

- `default.nix` (openssh + samba) is consumed **only by rpi**; dobby imports files individually.
- `samba.nix` hardcodes `dobby`/`/mnt/hdd` yet leaks onto rpi via `server/default.nix`.
- `glance/`: `default.nix` is aggregator + dashboard; `widgets/*.nix` are **not modules**
  (plain attrsets/functions read via `import`), `templates/` are HTML.
- `gameserver/`: `steam.nix` imported twice (`default.nix` + `valheim.nix`).
- `homebridge/`: single-file tree + two shell scripts copied via `runCommand`.
- Cross-tree coupling: `valheim.nix` consumes `RESTIC_PASSWORD` (declared in `immich.nix`)
  and `message-board.service` (defined in `glance/message-board.nix`).

### `home/`

- Two entry points: `desktop.nix` (13 imports, `stateVersion 26.05`) and
  `server.nix` (4 imports, `stateVersion 25.11`, depends on `home.nvim.lsp.enable`).
- `mkHM` hardcodes user `nic`; HM is embedded as a NixOS module (`osConfig` available).
- Two genuine HM modules declare options: `nvim/default.nix` (`home.nvim.lsp.enable`)
  and `dux/airpods.nix` (`services.librepods.*`).
- Two plain package functions shared with flake `packages`: `tools/mux-session/package.nix`,
  `agents/opencode/package.nix`.
- `noctalia/**` is **orphaned**: commented import in `desktop.nix`, and
  `inputs.noctalia` is not declared in `flake.nix` → dead code.

### `hosts/`

- 4 dirs; each `default.nix` is a self-contained host module importing its
  `hardware-configuration.nix`; `laptop` also imports `power.nix`.
- Hardware files read `config.hardware.enableRedistributableFirmware` (only desktop sets it true).
- No `microvm` host exists despite README/`.sops.yaml` references.
- `deploy.nix` node keys mirror `nixosConfigurations` (except `raspberry-pi` → hostname `rpi`).

### Infra coupling

- Host names are hardcoded in **7 places**: `flake.nix` configs + checks,
  `deploy.nix` nodes, `.github/workflows/cache-pr.yaml` matrix, `mise.toml`
  (`switch-all-hosts`/`cleanup-all-hosts`), `deploy-nodes.nix` default list,
  `hosts/dobby` override, and per-host `hostName`/`hostPlatform`.
- `nixosConfigurations` must remain standard outputs (deploy-rs `activateNode` depends on them).
- `.sops.yaml` regex is anchored to `secrets/secrets.yaml`; `sops.nix` + `home/desktop.nix`
  use relative paths to it.

### Docs

- `README.md`, `docs/{ARCHITECTURE,MODULES,HOSTS,PROGRAMS,NIXARCHY}.md` describe an old
  2-host KDE + Nixarchy + microVM world — largely stale.
- `docs/{setup-raspberry-pi,setup-sops,harmonia-cache}.md` are mostly current (with
  minor path/key drift); `DEPLOYMENT_SUMMARY.md` duplicates the Pi guide.

---

## Target Architecture (dendritic)

### Principles

- Every `.nix` file (except `flake.nix` and excluded helpers) is a **top-level flake-parts module**.
- The **path names the feature**; files are freely movable/splittable.
- Lower-level modules (NixOS / home-manager) are stored as option values using
  `lib.types.deferredModule`, enabling value merging under distinct names.
- Hosts compose **features by name**; there is no manual `imports` fan-out.

### Proposed structure

```
flake.nix                 # flake-parts mkFlake entry (inputs + lib + auto-import)
modules/                  # auto-imported flake-parts tree
  _lib/                   # excluded helpers: mkNixosSystem, module-class options
  nixos/
    common/<feature>.nix  # sets flake.modules.nixos.common-<feature>
    desktop/<feature>.nix
    server/<feature>.nix
    server/glance/default.nix
    server/glance/_widgets/   # excluded (plain attrset helpers)
    server/glance/_templates/
    server/homebridge/default.nix (+ _scripts/)
  home/<feature>.nix      # sets flake.modules.homeManager.<feature>
  home/_packages/         # excluded package.nix helpers (mux-session, opencode)
  hosts/<host>.nix        # nixosConfigurations.<host> = { modules = [ ...feature names... ]; }
  outputs/deploy.nix
  outputs/checks.nix
  outputs/packages.nix
  outputs/devshell.nix
hosts/<host>/hardware-configuration.nix   # kept as host-local data, referenced by host module
```

### Key mechanisms

- `lib` module declares `flake.modules.nixos` / `flake.modules.homeManager` as
  `attrsOf deferredModule`; feature modules contribute `flake.modules.nixos.<name>`.
- A host module builds `nixosConfigurations.<host>` with `nixpkgs.lib.nixosSystem`,
  wiring `sops-nix` + `home-manager` and composing the chosen feature modules by name
  (replacing `mkSystem`/`mkHM`).
- `inputs` reach lower-level modules via `specialArgs`/`extraSpecialArgs` (preserved),
  but cross-file values now live on the top-level `config` instead of `specialArgs` pass-through.
- `import-tree` auto-imports the `modules/` tree; `/_`-prefixed paths and `*.pkg.nix`
  helpers are excluded from module evaluation.

---

## Design Decisions

1. **Full dendritic** via flake-parts (`github:hercules-ci/flake-parts`) +
   import-tree (`github:denful/import-tree`), per user choice.
2. **Remove dead code**: `home/noctalia/`, microvm references, stale doc claims.
3. **Keep `.sops.yaml` `host_vm` recipient** (user choice) — do not touch recipients.
4. Keep home-manager **embedded as a NixOS module** (current behavior).
5. Preserve the `nixosConfigurations.{desktop,laptop,dobby,raspberry-pi}` contract
   (deploy-rs, checks, CI depend on it); derive host lists from `nixosConfigurations` where possible.
6. Staged migration, verifying `nix flake check` after each major tree.

---

## Constraints & Risks

- Not every `.nix` file is a module (`package.nix`, `widgets/*.nix`, `deploy.nix`) — must be excluded from auto-import.
- `common` is **not** universal: rpi deliberately omits docker/binfmt/glances/lunix/syncthing.
- `sops.nix`'s relative `defaultSopsFile` path breaks if moved to a different depth.
- Cross-tree secrets: `valheim.nix` → `RESTIC_PASSWORD` (declared in `immich.nix`).
- `specialArgs`/`extraSpecialArgs` and `inputs.*` usage must survive in the new host builder.
- `package.nix` files are consumed twice (module tree + flake `packages`); keep arity stable.
- Host-name contracts span flake, deploy, checks, CI, mise, and dobby's auto-deploy list.

---

## Step-by-step strategy

1. **Scaffold** (todo 1–2): add inputs, `mkFlake`, `_lib` options, exclusion conventions.
2. **System modules** (todo 3–5): common → desktop → server (+ subtrees).
3. **Home modules** (todo 6): migrate `home/`, isolate package helpers.
4. **Hosts** (todo 7): convert to composition modules.
5. **Outputs & automation** (todo 8–9): deploy/checks/packages/devShell/CI/mise.
6. **Cleanup & docs** (todo 10–11).
7. **Verify** (todo 12).
