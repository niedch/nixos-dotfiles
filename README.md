# nixos-dotfiles

Multi-host NixOS + Hyprland configuration.

## Usage

```bash
sudo nixos-rebuild switch --flake .#desktop
```

## Structure

```
├── flake.nix              # Flake entry point
├── hosts/
│   └── desktop/           # Desktop host config (QEMU/KVM VM)
├── home/
│   ├── common/            # Central home-manager config
│   ├── hyprland/          # Hyprland window manager config
│   ├── mise/              # Mise dev tool version manager
│   ├── nvim/              # Neovim (LazyVim) + dev tools
│   └── zsh/               # Zsh + oh-my-zsh + custom scripts
└── modules/
    └── common/
        └── hyprland.nix   # System-level Hyprland enable
```

## Components

| Path | Description |
|---|---|
| `hosts/desktop/` | NixOS host config: hostname `nixos`, user `nic`, GRUB boot, Vienna timezone |
| `home/hyprland/` | Hyprland WM with Lua config, autostart waybar/dunst, vim-style keybinds |
| `home/zsh/` | Oh-my-zsh with fzf, custom shell scripts (aliases, git, kube, mise, etc.) |
| `home/nvim/` | LazyVim-based Neovim config with plugins for Go, Rust, Java, TypeScript |
| `home/mise/` | Mise config managing tools (java, node, rust, maven, opencode, etc.) |
| `modules/common/` | Shared NixOS modules (Hyprland system enable, env vars) |

## Adding a new host

1. Create a new directory under `hosts/` (e.g. `hosts/laptop/`)
2. Add a new `nixosConfigurations.laptop = ...` entry in `flake.nix`
3. Rebuild with `sudo nixos-rebuild switch --flake .#laptop`
