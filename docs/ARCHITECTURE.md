# Architecture

This flake defines two NixOS configurations (`desktop` and `server`) with home-manager embedded as a NixOS module.

## Data flow

```
flake.nix
  │
  ├── inputs
  │   ├── nixpkgs (nixpkgs-unstable)
  │   └── home-manager (master, follows nixpkgs)
  │
  ├── outputs.nixosConfigurations.desktop
  │     │
  │     ├── hosts/virtual-machine              # Host-specific config
  │     │   ├── default.nix            # Hostname, user, boot, networking
  │     │   └── hardware-configuration.nix  # Auto-generated hardware config
  │     │
  │     ├── modules/common             # Shared system-level modules
  │     │   ├── docker.nix             # Docker daemon
  │     │   └── users.nix              # User accounts
  │     │
  │     ├── modules/desktop            # Desktop-only system modules
  │     │   ├── kde.nix                # KDE Plasma 6 + SDDM
  │     │   └── fonts.nix             # Desktop fonts
  │     │
  │     └── home-manager (embedded NixOS module)
  │           └── home-manager.users.nic
  │                 └── home/desktop.nix
  │                       ├── home/nvim       # Neovim + dev tools
  │                       ├── home/zsh        # Zsh + oh-my-zsh + scripts
  │                       └── home/mise       # Mise dev tool version manager
  │
  └── outputs.nixosConfigurations.server
        │
        ├── hosts/server               # Host-specific config
        │   ├── default.nix            # Hostname, boot, networking
        │   └── hardware-configuration.nix  # Hardware config
        │
        ├── modules/common             # Shared system-level modules
        │
        ├── modules/server             # Server-only system modules
        │   └── openssh.nix            # SSH daemon + firewall
        │
        └── home-manager (embedded NixOS module)
              └── home-manager.users.nic
                    └── home/server/default.nix
                          ├── home/tmux     # Tmux + scripts
                          ├── home/zsh      # Zsh + oh-my-zsh + scripts
                          └── home/nvim     # Neovim + dev tools
```

## Key design decisions

- **Multiple flake outputs** under `nixosConfigurations`. Home-manager is wired in via `home-manager.nixosModules.home-manager`, not as a standalone flake output.
- **All inputs** (`home-manager`, `sops-nix`, etc.) are passed to both NixOS and home-manager modules via `specialArgs` / `extraSpecialArgs`.
- **Home-manager backup** is enabled (`backupFileExtension = "backup"`) to prevent collisions with existing dotfiles.
- **Modules split by role**: Desktop-only modules (KDE Plasma 6, SDDM, fonts) live in `modules/desktop/`. Server-only modules (SSH, firewall) live in `modules/server/`. Shared modules (Docker, users) live in `modules/common/`.

## Three layers of configuration

| Layer | Scope | Desktop entry point | Server entry point |
|---|---|---|---|
| System (NixOS) | Hostname, users, boot, networking, system packages | `hosts/desktop/default.nix` | `hosts/server/default.nix` |
| Shared modules | System-wide features (Docker, users) | `modules/common/default.nix` | `modules/common/default.nix` |
| Role modules | Desktop or server specific features | `modules/desktop/default.nix` | `modules/server/default.nix` |
| User (home-manager) | User packages, dotfiles, shell, editors | `home/desktop.nix` | `home/server/default.nix` |
