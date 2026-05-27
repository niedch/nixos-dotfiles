# Adding programs

Programs can be installed at two levels: **system-wide** (available to all users) or **user-level** (only for user `nic`).

## User-level packages (home-manager)

Most GUI apps, CLI tools, and dev tools go here. Edit `home/common/default.nix`:

```nix
{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    git
    waybar
    wofi
    dunst
    wl-clipboard
    ghostty
    opencode
    firefox            # added
    ripgrep            # added
  ];
}
```

Then rebuild:

```bash
sudo nixos-rebuild switch --flake .#desktop
```

### Installed via dedicated modules

Some packages are better organized as self-contained modules under `home/<name>/`:

| Module | Packages | Config deployed |
|---|---|---|
| `home/nvim/` | `neovim`, `nodejs`, `go`, `cargo`, `rustc`, `gcc` | `~/.config/nvim/` |
| `home/zsh/` | `fzf` | `~/.config/zsh/` |
| `home/mise/` | `mise` | `~/.config/mise/config.toml` |
| `home/hyprland/` | *(comes from flake input)* | `~/.config/hypr/hyprland.lua` |

To add a program with its own dotfiles, [create a new module](MODULES.md#adding-a-new-home-manager-module).

## System-wide packages (NixOS)

Use for packages that need root-level permissions or should be available to all users. Edit `hosts/desktop/default.nix`:

```nix
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
  ];
}
```

## Declarative program config

home-manager provides dedicated modules for many programs. These handle both installation and config:

```nix
{ ... }:

{
  programs.git = {
    enable = true;
    userName = "your name";
    userEmail = "your@email.com";
  };

  programs.bash.enable = true;

  programs.firefox.enable = true;
}
```

Browse all available modules at https://nix-community.github.io/home-manager/options.html.

## Quick reference

| Goal | File | How |
|---|---|---|
| Install a CLI/GUI tool | `home/common/default.nix` | Add to `home.packages` |
| Install a tool + its dotfiles | New file under `home/<name>/` | Create module, import in `home/common/default.nix` |
| Install system-wide | `hosts/desktop/default.nix` | Add to `environment.systemPackages` |
| Use home-manager declarative module | `home/common/default.nix` or new module | Use `programs.<name>` |
