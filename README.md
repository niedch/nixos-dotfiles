# nixos-dotfiles

Multi-host NixOS + Hyprland configuration managed via flakes and home-manager.

## Demo

https://github.com/user-attachments/assets/e0bab9e3-ae21-42dc-b0bd-6bb02382538f

## Hosts

| Host       | Type        | Hostname | Boot        | Key Features                              |
|------------|-------------|----------|-------------|-------------------------------------------|
| `desktop`  | QEMU/KVM VM | `nixos`  | GRUB        | Desktop VM, virtio GPU, QEMU guest tools  |
| `laptop`   | Physical    | `nixos`  | systemd-boot | Dell Precision 5530, NVIDIA, Bluetooth, CUPS, PipeWire |
| `dobby`    | Server      | `dobby`  | systemd-boot | Minimal, no desktop, SSH-only             |
| `raspberry-pi` | Physical | `rpi`    | extlinux     | Raspberry Pi (aarch64), minimal SSH       |
| `microvm`   | MicroVM     | `microvm` | N/A         | Try-before-you-buy, runnable via `nix run` |

> Try out this configuration in a MicroVM:
> ```
> nix run github:niedch/nixos-dotfiles#microvm
> ```

## Usage

```bash
sudo nixos-rebuild switch --flake .#desktop       # Desktop VM
sudo nixos-rebuild switch --flake .#laptop        # Dell Precision 5530
sudo nixos-rebuild switch --flake .#dobby         # Server
sudo nixos-rebuild switch --flake .#raspberry-pi  # Raspberry Pi (aarch64)
```

## Architecture

Three-layer design:

```
flake.nix                     # Entry point, defines hosts + flake inputs
├── hosts/<host>/             # Host-specific NixOS config (hardware, boot, locale)
├── modules/                  # Reusable NixOS system modules
│   ├── common/               #   Shared by all hosts (docker, sops, users, ssh)
│   ├── desktop/              #   Desktop-only (Hyprland, Ly, fonts)
│   └── server/               #   Server-only (SSH daemon, firewall)
└── home/                     # Home-manager user configs
    ├── desktop.nix           #   Full desktop config (15+ submodules)
    └── server.nix            #   Minimal server config (3 submodules)
```

## Key Components

| Path | Description |
|------|-------------|
| `hosts/` | Per-host NixOS configs — hardware, bootloader, kernel (desktop VM, laptop, dobby, rpi, microvm) |
| `modules/common/` | Shared modules: Docker, SOPS secrets, SSH, users, binfmt (aarch64 emulation) |
| `modules/desktop/` | Desktop modules: Hyprland compositor, Ly display manager, JetBrains Mono font |
| `modules/server/` | Server modules: SSH daemon, firewall |
| `home/` | Home-manager configs: Hyprland (Lua), Quickshell bar (QML), Ghostty terminal, Neovim (LazyVim), Zsh, Tmux, Chromium web apps, Omarchy themes (20+), and more |
| `secrets/` | SOPS-encrypted with age key recipients |
| `mise.toml` | Task runner (`mise run build/switch/format/cleanup`) |
| `.github/workflows/` | CI for Nix store caching and pre-built paths |

## Secrets

Secrets are encrypted with [SOPS](https://github.com/getsops/sops) using [age](https://age-encryption.org/). Two recipients are configured — admin key and laptop key. Secrets are stored in `secrets/secrets.yaml` and decrypted at build time via `sops-nix`.

## Theming

The [Omarchy theme system](https://github.com/niedch/nix-omarchy-theme) provides 20+ themes (kanso, catppuccin, nord, tokyo-night, gruvbox, etc.), symlinked to Hyprland, Waybar, Walker, and mako configs. Default theme: `kanso`.

## Chromium web apps

`home/chromium/` registers web apps as desktop entries via `xdg.desktopEntries`, each launching in an app window under Chromium. Favicons are auto-fetched at build time using Google's favicon API.

### Adding a new web app

Add one line to the `webApps` list in `home/chromium/default.nix:32`:

```nix
{ name = "App Name"; domain = "example.com"; url = "https://example.com"; sha256 = "..."; }
```

To get the `sha256` hash for a new app:

```bash
# First build with --impure to download the favicon
nix build '.#nixosConfigurations.desktop' --impure
# Get the hash from the cached download
nix hash file $(ls /nix/store/*-App-Name-favicon)
```

Then fill the hash into the `webApps` entry — subsequent builds are fully pure.

## Adding a new host

1. Create a new directory under `hosts/` (e.g. `hosts/new-host/`)
2. Add a `nixosConfigurations.new-host = ...` entry in `flake.nix`, importing `modules/common` and optionally `modules/desktop` or `modules/server`
3. Create a corresponding home-manager entry point under `home/` if needed
4. Rebuild with `sudo nixos-rebuild switch --flake .#new-host`
