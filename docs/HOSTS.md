# Multi-host setup

The flake is structured to support multiple hosts. Currently `desktop` and `server` are defined.

## How it works

Each host lives under `hosts/<name>/` and is registered in `flake.nix` under `nixosConfigurations`. All hosts share the same `modules/common` (Docker, users). Desktop and server have their own role-specific modules:

- `modules/desktop/` - Hyprland, display manager, fonts
- `modules/server/` - SSH, firewall

Home-manager configs are also split:
- `home/common/` - Full desktop config (all modules)
- `home/server/` - Minimal server config (tmux, zsh, nvim only)

## Adding a new host

### 1. Create a host directory

```bash
mkdir -p hosts/laptop
nixos-generate-config --root /mnt --dir ./hosts/laptop
```

This generates `hardware-configuration.nix` automatically. Create `default.nix` by hand:

```nix
# hosts/laptop/default.nix
{ pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  boot.loader.systemd-boot.enable = true;

  networking.hostName = "laptop";

  networking.networkmanager.enable = true;
  time.timeZone = "Europe/Vienna";

  programs.zsh.enable = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "25.11";
}
```

### 2. Register in `flake.nix`

Add a new entry alongside existing hosts:

```nix
nixosConfigurations = {
  desktop = nixpkgs.lib.nixosSystem { ... };

  laptop = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };
    modules = [
      ./hosts/laptop
      ./modules/common
      ./modules/desktop  # or ./modules/server
      home-manager.nixosModules.home-manager {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.backupFileExtension = "backup";
        home-manager.extraSpecialArgs = { inherit inputs; };
        home-manager.users.nic = import ./home/common/default.nix;
      }
    ];
  };
};
```

### 3. Rebuild

```bash
sudo nixos-rebuild switch --flake .#laptop
```

## Per-host overrides

If a host needs different home-manager config, create a variant under `home/` (e.g. `home/laptop/`) and reference it instead of `home/common/default.nix`.

## Server setup

The server configuration uses:
- `modules/common/` - Shared modules (Docker, users)
- `modules/server/` - Server-specific modules (SSH, firewall)
- `home/server/` - Minimal home config (tmux, zsh, nvim only)

To customize the server, edit files in `modules/server/` and `home/server/`.
