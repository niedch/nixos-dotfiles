# Modules

There are two kinds of modules in this setup: **NixOS system modules** and **home-manager user modules**.

## NixOS system modules (`modules/common/`)

System modules configure system-wide features: services, kernel modules, packages available to all users, etc.

### Current modules

| File | Purpose |
|---|---|
| `default.nix` | Imports all submodules (add new modules here) |
| `hyprland.nix` | Enables Hyprland, sets `NIXOS_OZONE_WL`, enables polkit + GPU |

### Adding a new system module

1. Create a file in `modules/common/`:

```nix
# modules/common/docker.nix
{ config, pkgs, ... }:

{
  virtualisation.docker.enable = true;
  users.users.nic.extraGroups = [ "docker" ];
}
```

2. Import it in `modules/common/default.nix`:

```nix
{...}:
{
  imports = [
    ./hyprland.nix
    ./docker.nix
  ];
}
```

That's it — it's now active for all hosts.

### Modules that need input access

If your module needs flake inputs (e.g. a pinned package from a flake input), add `inputs` to the function args. It's passed through automatically via `specialArgs` in `flake.nix`:

```nix
{ config, pkgs, inputs, ... }:
{
  # inputs.hyprland, inputs.home-manager, etc. available here
}
```

## Home-manager modules (`home/<name>/`)

Home-manager modules configure user-level features: dotfiles, user packages, shell config, window manager keybinds.

### Current modules

| Path | Purpose |
|---|---|
| `home/common/default.nix` | Central entry point, imports all submodules |
| `home/hyprland/` | Hyprland WM config (Lua keybinds, autostart) |
| `home/zsh/` | Zsh + oh-my-zsh + custom scripts |
| `home/nvim/` | Neovim (LazyVim) + dev tools |
| `home/mise/` | Mise version manager + tool config |

### Adding a new home-manager module

1. Create a directory under `home/`:

```nix
# home/kitty/default.nix
{ config, pkgs, ... }:

{
  home.packages = with pkgs; [ kitty ];

  xdg.configFile."kitty/kitty.conf".source = ./kitty.conf;
}
```

2. Import it in `home/common/default.nix`:

```nix
{
  imports = [
    ../hyprland
    ../nvim
    ../zsh
    ../mise
    ../kitty
  ];
}
```

### Deployment patterns

| Pattern | Use case | Example |
|---|---|---|
| `home.packages` | Install user packages | `pkgs.kitty` |
| `xdg.configFile` | Deploy dotfiles | `source = ./kitty.conf` |
| `programs.<name>` | Use home-manager's declarative module | `programs.zsh`, `programs.git` |
| `wayland.windowManager` | WM config | `wayland.windowManager.hyprland` |
