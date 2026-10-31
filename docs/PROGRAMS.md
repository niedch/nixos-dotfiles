# Adding programs

Programs can be installed at two levels: **system-wide** (available to all users) or **user-level** (only for user `nic`).

## User-level packages (home-manager)

Most GUI apps, CLI tools, and dev tools go here. Edit `home/desktop.nix`:

```nix
{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    git
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

## Nixarchy apps catalogue (`programs.nixarchy.apps.*`)

For desktop hosts running the Nixarchy environment (`laptop`, `desktop`), applications can be managed via Nixarchy's declarative apps catalogue.

### Why use Nixarchy apps?
- **Desktop & Session Integration**: Automatically configures Omarchy application launcher entries, hotkeys, and Wayland window rules.
- **Dynamic Theming**: Applications compatible with the theme engine automatically follow Omarchy's runtime palette changes.
- **Packaging Wrappers**: Automatically provisions necessary polkit rules, setuid helpers, and FHS runtime wrappers (for instance, `apps._1password` sets up polkit authentication; `apps.steam` sets up the 32-bit FHS container).

### Configuring apps

Edit `hosts/laptop/nixarchy/apps.nix` (per-host) or `modules/desktop/nixarchy.nix` (desktop baseline):

```nix
{ pkgs, ... }: {
  programs.nixarchy.apps = {
    # Terminals
    ghostty.enable = true;

    # Media & Productivity
    spotify.enable = true;
    obsidian.enable = true;

    # Gaming & Drivers
    xbox-controllers.enable = true;

    # Editors & Browsers
    zed.enable = true;
    firefox = {
      enable = true;
      settings = {
        policies.DisableTelemetry = true;
      };
    };
  };
}
```

For the full list of available applications across AI, Browsers, Development, Editors, Gaming, Terminals, and Services, see the **[Nixarchy Applications Catalogue](NIXARCHY.md#6-applications-catalogue-programsnixarchyapps)** in the [Nixarchy Configuration Guide](NIXARCHY.md).

## Quick reference

| Goal | File | How |
|---|---|---|
| Install a CLI/GUI tool | `home/desktop.nix` | Add to `home.packages` |
| Install a tool + its dotfiles | New file under `home/<name>/` | Create module, import in `home/desktop.nix` |
| Install system-wide | `hosts/desktop/default.nix` | Add to `environment.systemPackages` |
| Use home-manager declarative module | `home/desktop.nix` or new module | Use `programs.<name>` |
| Install via Nixarchy apps catalogue | `hosts/laptop/nixarchy/apps.nix` | Set `programs.nixarchy.apps.<name>.enable = true` |
