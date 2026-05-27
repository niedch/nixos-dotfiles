# Architecture

This flake defines a single NixOS configuration (`desktop`) with home-manager embedded as a NixOS module.

## Data flow

```
flake.nix
  │
  ├── inputs
  │   ├── nixpkgs (nixos-25.11)
  │   ├── home-manager (release-25.11, follows nixpkgs)
  │   └── hyprland (github:hyprwm/Hyprland)
  │
  └── outputs.nixosConfigurations.desktop
        │
        ├── hosts/desktop              # Host-specific config
        │   ├── default.nix            # Hostname, user, boot, networking
        │   └── hardware-configuration.nix  # Auto-generated hardware config
        │
        ├── modules/common             # Shared system-level modules
        │   └── hyprland.nix           # Hyprland system enable + env vars
        │
        └── home-manager (embedded NixOS module)
              └── home-manager.users.nic
                    └── home/common/default.nix
                          ├── home/hyprland   # Hyprland user config + keybinds
                          ├── home/nvim       # Neovim + dev tools
                          ├── home/zsh        # Zsh + oh-my-zsh + scripts
                          └── home/mise       # Mise dev tool version manager
```

## Key design decisions

- **Single flake output** under `nixosConfigurations`. Home-manager is wired in via `home-manager.nixosModules.home-manager`, not as a standalone flake output.
- **All inputs** (`hyprland`, `home-manager`) are passed to both NixOS and home-manager modules via `specialArgs` / `extraSpecialArgs`.
- **Home-manager backup** is enabled (`backupFileExtension = "backup"`) to prevent collisions with existing dotfiles.

## Three layers of configuration

| Layer | Scope | Entry point |
|---|---|---|
| System (NixOS) | Hostname, users, boot, networking, system packages | `hosts/desktop/default.nix` |
| Shared modules | System-wide features (Hyprland, env vars) | `modules/common/default.nix` |
| User (home-manager) | User packages, dotfiles, shell, editors, WM config | `home/common/default.nix` |
