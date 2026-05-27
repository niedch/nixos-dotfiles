# Multi-host setup

The flake is structured to support multiple hosts. Currently only `desktop` is defined.

## How it works

Each host lives under `hosts/<name>/` and is registered in `flake.nix` under `nixosConfigurations`. All hosts share the same `modules/common` and the same `home/common` home-manager config.

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

  users.users.nic = {
    description = "Christoph";
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.zsh;
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  environment.pathsToLink = [ "/share/applications" "/share/xdg-desktop-portal" ];

  system.stateVersion = "25.11";
}
```

### 2. Register in `flake.nix`

Add a new entry alongside `desktop`:

```nix
nixosConfigurations = {
  desktop = nixpkgs.lib.nixosSystem { ... };

  laptop = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };
    modules = [
      ./hosts/laptop
      ./modules/common
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
