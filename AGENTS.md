# AGENTS.md

## Dev shell & task runner

Enter the development shell with `nix develop` (or just `nix develop .`). This provides `mise`, `alejandra`, and `jq`. Tasks are defined in `mise.toml` and run via `mise run <task>`:

```bash
mise run format                     # alejandra (no config file; default settings)
mise run build <host>               # nix build (dry-run, no sudo)
mise run switch <host>              # sudo nixos-rebuild switch
mise run remote-switch <host> <target>  # SSH remote deploy (for rpi)
mise run cleanup                    # sudo nix-collect-garbage -d
mise run update-nix-omarchy-theme   # nix flake update nix-omarchy-theme
mise run rebuild <host>             # git add + auto-commit message (Gemini) + switch
```

## Host naming mismatch

Host directory names differ from flake `nixosConfigurations` keys:

| Directory                | Flake key        |
|--------------------------|------------------|
| `hosts/virtual-machine/` | `desktop`        |
| `hosts/laptop/`          | `laptop`         |
| `hosts/dobby/`           | `dobby`          |
| `hosts/rpi/`             | `raspberry-pi`   |

Always use the **flake key** in commands (e.g. `mise run switch desktop`).

## Architecture

- **4 NixOS hosts** with home-manager embedded as a NixOS module (not standalone flake output).
- **3-layer module system**: `hosts/` (per-host hardware/boot) → `modules/` (reusable NixOS modules) → `home/` (home-manager user configs).
- **Desktop/laptop** import `modules/common` + `modules/desktop` + `home/desktop.nix`.
- **Dobby** imports `modules/common` + `modules/server` + `home/server.nix`.
- **Raspberry-pi** imports modules **selectively** (only `sops.nix`, `ssh.nix` from common, plus `modules/server`, `home/server.nix`, and an extra `home-assistant.nix` module). Do not blindly add `modules/common` to rpi.

## State versions

State versions are inconsistent across hosts. Do not change them or normalize them without explicit instruction.

## Formatting

Run `mise run format` before committing. Uses `alejandra` with defaults.

## No CI, no tests

There are no automated tests, linting, or CI workflows. Changes are verified by building (`mise run build <host>`) or switching (`mise run switch <host>`).

## Secrets

Secrets are SOPS-encrypted in `secrets/secrets.yaml` with 4 age recipients (admin key + host keys for laptop, VM, rpi). Edit with `sops secrets/secrets.yaml`. The decryption key paths differ: desktop/laptop use `/home/nic/.config/sops/age/keys.txt` (user-level), servers use `/etc/ssh/ssh_host_ed25519_key` (host key).

## Cross-arch builds

`modules/common/binfmt.nix` enables aarch64 emulation on all x86 hosts for building Raspberry Pi derivations. The rpi host sets `nix.settings.require-sigs = false` to allow cross-compiled binaries.

## Adding a chromium web app

1. Add entry to `webApps` list in `home/chromium/default.nix:32` with a placeholder sha256.
2. Run `nix build '.#nixosConfigurations.desktop' --impure` (must be `--impure` to download favicon).
3. Get hash from `nix hash file $(ls /nix/store/*-App-Name-favicon)`.
4. Fill the hash and rebuild normally (no `--impure` needed).

## Adding a host

1. Create `hosts/<name>/` with `default.nix` + `hardware-configuration.nix`.
2. Add `nixosConfigurations.<key>` entry in `flake.nix`.
3. Add corresponding home-manager config under `home/` if needed.
4. Update README.md host table.

## Documentation

- `docs/ARCHITECTURE.md` — partially outdated (references old host names and channel versions), but the design principles are still valid. Trust the README and `flake.nix` over it.
- `docs/setup-raspberry-pi.md` — comprehensive cross-compilation setup guide for the Pi.
