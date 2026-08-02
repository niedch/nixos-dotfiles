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

## Structure

```
├── flake.nix                  # Flake entry point — 4 NixOS configurations
├── flake.lock                 # Pinned flake inputs
├── .sops.yaml                 # SOPS age key configuration
├── secrets/
│   └── secrets.yaml           # Encrypted secrets
├── hosts/
│   ├── virtual-machine/       # Desktop VM host (GRUB, QEMU guest)
│   ├── laptop/                # Dell Precision 5530 (NVIDIA, Bluetooth, CUPS)
│   ├── dobby/                 # Server host (minimal, SSH)
│   └── rpi/                   # Raspberry Pi (aarch64, minimal SSH)
├── modules/
│   ├── common/                # Shared system modules
│   │   ├── binfmt.nix         # QEMU binfmt for cross-arch builds (aarch64)
│   │   ├── docker.nix         # Docker daemon + auto-prune
│   │   ├── sops.nix           # SOPS secrets configuration
│   │   ├── ssh.nix            # SSH server enable
│   │   └── users.nix          # User "nic" definition
│   ├── desktop/               # Desktop system modules
│   │   ├── displaymanager.nix # Ly display manager
│   │   ├── fonts.nix          # JetBrains Mono Nerd Font + Omarchy font
│   │   └── hyprland.nix       # Hyprland system enable + Wayland env
│   └── server/                # Server system modules
│       └── openssh.nix        # SSH daemon config + firewall
└── home/
    ├── desktop.nix            # Desktop home-manager entry point
    ├── server.nix             # Server home-manager entry point
    ├── hyprland/              # Hyprland WM (Lua config, vim keybinds)
    ├── quickshell/            # Quickshell status bar (QML config)
    ├── walker/                # Walker launcher + Elephant backend
    ├── ghostty/               # Ghostty terminal emulator
    ├── kdenlive/              # Kdenlive video editor config
    ├── obsidian/              # Obsidian note-taking app config
    ├── themes/                # Omarchy theme system (20+ themes)
    ├── tmux/                  # Tmux config + sessionizer scripts
    ├── mux-session/           # Tmux session manager with project configs
    ├── nvim/                  # Neovim (LazyVim) + Go/Rust/TS toolchain
    ├── zsh/                   # Zsh + oh-my-zsh + custom scripts
    ├── mise/                  # Mise version manager
    ├── git/                   # Git user config
    ├── chromium/              # Chromium browser + webapp desktop entries with auto-fetched favicons
    ├── ssh/                   # SSH client config + SOPS-managed keys
    └── opencode/              # Opencode AI agent with custom agents
```

## Flake Inputs

| Input | Source | Purpose |
|-------|--------|---------|
| `nixpkgs` | nixos-26.05 | Main package repository |
| `home-manager` | release-26.05 | User-level config management |
| `hyprland` | Hyprwm/Hyprland | Wayland compositor |
| `nix-omarchy-theme` | niedch/nix-omarchy-theme | Theme framework |
| `sops-nix` | Mic92/sops-nix | Secrets management |
| `nixos-hardware` | NixOS/nixos-hardware | Hardware profiles (Dell 5530) |
| `wlctl` | aashish-thapa/wlctl | Wayland display manager controller |

## Key Components

| Path | Description |
|------|-------------|
| `hosts/virtual-machine/` | Desktop VM host: hostname `nixos`, GRUB boot, QEMU guest tools |
| `hosts/laptop/` | Laptop host: Dell Precision 5530, NVIDIA legacy 580, PipeWire, CUPS, Bluetooth |
| `hosts/dobby/` | Server host: minimal, SSH-only, no desktop |
| `modules/common/` | Shared NixOS modules (Docker, SOPS, SSH, users) |
| `modules/desktop/` | Desktop system modules (Hyprland, Ly DM, fonts) |
| `modules/server/` | Server system modules (SSH daemon, firewall) |
| `home/desktop.nix` | Full desktop home-manager entry point |
| `home/server.nix` | Minimal server home-manager entry point |
| `home/hyprland/` | Hyprland WM with Lua config, vim-style keybinds, window rules |
| `home/quickshell/` | Quickshell status bar with QML widgets, cava audio viz, and popups |
| `home/walker/` | Walker app launcher + Elephant backend as systemd services |
| `home/ghostty/` | Ghostty terminal with JetBrains Mono, tmux auto-start |
| `home/kdenlive/` | Kdenlive video editor config |
| `home/obsidian/` | Obsidian note-taking app config |
| `home/themes/` | Omarchy theme system — 20+ themes symlinked to hypr/quickshell/walker configs |
| `home/tmux/` | Tmux with custom sessionizer, popup, and opener scripts |
| `home/mux-session/` | Tmux session manager with per-project configs |
| `home/nvim/` | LazyVim-based Neovim config with Go, Rust, Java, TypeScript tooling |
| `home/zsh/` | Oh-my-zsh with fzf, autosuggestions, custom shell scripts |
| `home/mise/` | Mise version manager (java, node, rust, maven, opencode) |
| `home/git/` | Git user config with autoSetupRemote and pull.rebase |
| `home/ssh/` | SSH client config with SOPS-managed ed25519 key |
| `home/chromium/` | Chromium browser + webapp desktop entries with auto-fetched favicons via `pkgs.fetchurl` + `imagemagick` |
| `home/opencode/` | Opencode AI coding agent with custom agents (build, plan, explore) |

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
