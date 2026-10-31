# Nixarchy Configuration & Options Guide

This document is a comprehensive configuration guide and options reference for **Nixarchy** (Omarchy on NixOS via Hyprland) within this repository and upstream Nixarchy.

---

## Table of Contents
1. [Overview & Architecture](#1-overview--architecture)
2. [Configuration Scopes & Flake Integration](#2-configuration-scopes--flake-integration)
3. [Core System Settings (`programs.nixarchy.*`)](#3-core-system-settings-programsnixarchy)
4. [Local AI & Coding Agents (`programs.nixarchy.localAi.*`)](#4-local-ai--coding-agents-programsnixarchylocalai)
5. [Services & System Infrastructure (`programs.nixarchy.services.*`)](#5-services--system-infrastructure-programsnixarchyservices)
6. [Applications Catalogue (`programs.nixarchy.apps.*`)](#6-applications-catalogue-programsnixarchyapps)
7. [Dynamic Theme Engine (`programs.nixarchyThemeEngine.*`)](#7-dynamic-theme-engine-programsnixarchythemeengine)
8. [Home Manager Integration & Plugins (`home-manager.users.<user>.programs.nixarchy.*`)](#8-home-manager-integration--plugins-home-managerusersuserprogramsnixarchy)
9. [Fleet Management & Maintenance (`programs.nixarchy.fleet.*`, `autoUpdate`)](#9-fleet-management--maintenance-programsnixarchyfleet-autoupdate)
10. [Common Recipes & Examples](#10-common-recipes--examples)

---

## 1. Overview & Architecture

### What is Nixarchy?
**Nixarchy** bridges [Omarchy](https://github.com/omarchy/omarchy) — an Arch-centric, keyboard-driven Wayland desktop environment built on [Hyprland](https://hyprland.org) — to [NixOS](https://nixos.org).

While upstream Omarchy relies on Arch-specific mechanisms (Pacman, AUR packages, mutable dotfile scripts, and fixed FHS filesystem hierarchies), Nixarchy re-architects Omarchy for declarative immutability:
- **Session Lifecycle via `uwsm`**: Wraps the Hyprland compositor in universal Wayland session management (`uwsm`), launching session components via dedicated systemd user units.
- **Declarative Package & App Layer**: Transforms mutable application installation menus into declarative NixOS options (`programs.nixarchy.apps.*`).
- **Binary Dynamic Linking Fixes (`nix-ld`)**: Automatically configures `nix-ld` with graphical, audio, and C/C++ runtime libraries so that downloaded un-patched Linux binaries, AppImages, and Language Server binaries function out of the box.
- **Dynamic Palette Synchronization**: Integrates Omarchy's live theming engine (`hyprchroma` / `omarchroma`) across GTK, Qt/KDE, terminal emulators (Ghostty, Foot, Kitty), browsers, Starship, and code editors without requiring a rebuild on every theme switch.
- **First-Class Home Manager Integration**: Provides modules that separate system-level privileges (e.g., setuid helpers, polkit policies, hardware graphics drivers) from user-level dotfiles and panel plugins.

### Architecture in this Repository

The configuration flow in this repository is structured as follows:

```
flake.nix
  │
  ├── inputs.nixarchy ("github:olafkfreund/nixarchy/release")
  │
  ├── outputs.nixosConfigurations.laptop / desktop
  │     │
  │     ├── modules/desktop/default.nix
  │     │     ├── imports inputs.nixarchy.nixosModules.nixarchy
  │     │     └── imports ./nixarchy.nix (Base system options, package overlays, defaults)
  │     │
  │     ├── hosts/laptop/nixarchy-apps.nix (Auto-maintained aggregator)
  │     │     ├── imports ./nixarchy/apps.nix      (Declarative apps catalogue)
  │     │     ├── imports ./nixarchy/services.nix  (Bundled & plain NixOS services)
  │     │     └── imports ./nixarchy/advanced.nix  (Host-specific Nixarchy tweaks)
  │     │
  │     └── (mkHM (import ./home/desktop.nix))
  │           └── imports ./home/nixarchy/default.nix
  │                 ├── imports inputs.nixarchy.homeManagerModules.nixarchy
  │                 ├── imports ./theme.nix
  │                 ├── imports ./hypr/
  │                 └── imports ./plugins/
```

- **`flake.nix`**: Tracks `inputs.nixarchy`, which follows this repository's pinned `nixpkgs`, `sops-nix`, and `home-manager`.
- **`modules/desktop/nixarchy.nix`**: Enables the desktop system-wide (`programs.nixarchy.enable = true`), designates the primary user (`programs.nixarchy.user = "nic"`), specifies the active flake path, applies patch workarounds for cursor fallbacks, and establishes baseline app/theme flags.
- **`hosts/laptop/nixarchy/`**: Contains per-host service declarations (`services.nix`), application toggles (`apps.nix`), and advanced overrides (`advanced.nix`).
- **`home/nixarchy/default.nix`**: Imports the Home Manager module (`homeManagerModules.nixarchy`), declares bar/panel plugins (`defaultPlugins`), configures Neovim adoption mode (`neovim = "off"` in favour of our dedicated LazyVim module), and links custom menu layouts.

---

## 2. Configuration Scopes & Flake Integration

Nixarchy evaluates across two distinct boundaries:

| Scope | Module Path | Responsibilities | Typical File Location |
|---|---|---|---|
| **NixOS System Module** | `inputs.nixarchy.nixosModules.nixarchy` | Display managers, hardware acceleration, PAM/Polkit rules, binary caches, system services (`ollama`, `tailscaled`, `syncthing`), setuid wrappers, and system packages. | `modules/desktop/nixarchy.nix`, `hosts/laptop/nixarchy/*.nix` |
| **Home Manager Module** | `inputs.nixarchy.homeManagerModules.nixarchy` | Waybar/Omarchy panel plugins, Neovim configuration sync, user menu schema (`nixarchy-menu.json`), user-level hooks, and local agent environment settings. | `home/nixarchy/default.nix`, `home/nixarchy/plugins/*.nix` |

### Flake Setup
In `flake.nix`:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixarchy = {
      url = "github:olafkfreund/nixarchy/release";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.sops-nix.follows = "sops-nix";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs = { self, nixpkgs, home-manager, nixarchy, ... } @ inputs: {
    nixosConfigurations.laptop = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [
        inputs.nixarchy.nixosModules.nixarchy
        ./modules/desktop/nixarchy.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.users.nic = {
            imports = [
              inputs.nixarchy.homeManagerModules.nixarchy
              ./home/nixarchy
            ];
          };
        }
      ];
    };
  };
}
```

---

## 3. Core System Settings (`programs.nixarchy.*`)

Core system settings configure the desktop foundation, binary caches, language servers, and shell integration.

### Options Table

| Option | Type | Default | Description |
|---|---|---|---|
| `programs.nixarchy.enable` | `bool` | `false` | Enables the Nixarchy desktop suite, including Hyprland session scripts, display manager integration, and runtime foundations. |
| `programs.nixarchy.user` | `str` | `"omarchy"` | The username of the primary interactive desktop user (e.g. `"nic"`). Used to assign group memberships (such as `input` for hotkeys and controllers) and configure user-specific services. |
| `programs.nixarchy.flake` | `nullOr path` | `null` | Absolute path to the host's configuration flake (e.g. `"/home/nic/Projects/nixos-dotfiles"`). Configures Git `safe.directory` rules so Git commands and rebuilding tools do not fail with dubious ownership errors. |
| `programs.nixarchy.package` | `package` | `pkgs.omarchy` | The core Omarchy package providing session scripts, QML assets, and Hyprland configuration files. Can be overridden with `.overrideAttrs` for upstream patches. |
| `programs.nixarchy.allowUnfree` | `bool` | `true` | Allows unfree packages required by proprietary applications in the apps catalogue (Chrome, Slack, Spotify, Steam, etc.). |
| `programs.nixarchy.preinstalls` | `bool` | `true` | Installs recommended default desktop tooling (utilities, archive tools, calculators, default fonts). |
| `programs.nixarchy.preinstallsExclude` | `listOf str` | `[]` | List of package names from the default preinstalls suite to omit from the system closure. |
| `programs.nixarchy.mcp` | `bool` | `false` | Enables the system Model Context Protocol (MCP) daemon, allowing coding assistants to query system state, NixOS options, and machine diagnostics. |
| `programs.nixarchy.aiMirror.mcp` | `bool` | `false` | Connects AI agents (Claude Code, Codex, opencode) to `ai-mirror`, allowing approved AI agents to inspect and drive the desktop session. |
| `programs.nixarchy.defaultAgent` | `nullOr str` | `null` | The primary agent launched by keyboard shortcuts and launcher entries (e.g., `"opencode"`, `"claude-code"`, or `"codex"`). |
| `programs.nixarchy.displayManager` | `enum ["sddm" "tuigreet" "none"]` | `"sddm"` | The graphical or console greeter used to start the session. When set to `"sddm"`, autologin and Wayland session profiles are wired automatically. |
| `programs.nixarchy.binaryCaches` | `bool` | `true` | Adds upstream Nixarchy and Hyprland Cachix binary caches (`nixarchy.cachix.org-1`, `hyprland.cachix.org-1`) to `nix.settings.substituters`. |
| `programs.nixarchy.cudaCache` | `bool` | `true` | Adds `cache.nixos-cuda.org` to binary cache substituters, preventing long local CUDA package rebuilds. |
| `programs.nixarchy.languageServer` | `bool` | `true` | Installs and configures `nixd` system-wide for Nix language server capabilities in editors. |
| `programs.nixarchy.nixdSettings` | `attrs` | `{}` | Attribute set merged into `nixd` configuration (e.g. evaluating options against `nixosConfigurations.<host>.options`). |
| `programs.nixarchy.language` | `nullOr str` | `null` | Locale/language identifier from Omarchy's locale registry for desktop localization. |
| `programs.nixarchy.bootSplash` | `enum ["defer" "force" "off"]` or `bool` | `"defer"` (or `true`) | Controls Plymouth boot splash configuration. `"defer"` respects existing boot splashes; `"force"` mandates the Nixarchy logo splash. |
| `programs.nixarchy.commandNotFound` | `bool` | `true` | Replaces standard command-not-found handlers with `nix-index-with-db`, suggesting `, <command>` for ad-hoc execution or `nixarchy pkg add`. |
| `programs.nixarchy.shellIntegration` | `bool` | `true` | Injects environment variables (`OMARCHY_PATH`, session tokens, and PATH adjustments) into Bash, Zsh, and Fish. |

---

## 4. Local AI & Coding Agents (`programs.nixarchy.localAi.*`)

Nixarchy includes a built-in local AI inference stack backed by **Ollama**, allowing coding agents (like `opencode` and `claude-code`) and system skills to operate without third-party network APIs or subscription keys.

### Acceleration & Hardware Matrix

| Hardware | Acceleration Value | NixOS Requirement |
|---|---|---|
| **NVIDIA GPU** | `"cuda"` | `hardware.nvidia.enabled = true` |
| **AMD GPU** | `"rocm"` | `hardware.amdgpu.opencl.enable = true` |
| **Vulkan-capable GPU** | `"vulkan"` | Generic Vulkan runtime; lightweight fallback when CUDA/ROCm SDK closures are undesirable. |
| **Automatic** | `"auto"` *(Default)* | Probes active NixOS hardware flags and chooses CUDA, ROCm, or CPU accordingly. |
| **CPU Only** | `"cpu"` | Requires explicit `allowCpu = true`. |

> **Why is `allowCpu = false` by default?**
> Local coding agents require multi-turn agentic loops with tool calls and context windows exceeding 32,000–65,536 tokens. On a CPU, a single question can take 15–30 minutes, leading to agent timeouts and failed tool executions. Nixarchy disables CPU execution by default so builds fail early with clear feedback rather than degrading silently.

### Options Table

| Option | Type | Default | Description |
|---|---|---|---|
| `programs.nixarchy.localAi.enable` | `bool` | `false` | Enables local LLM infrastructure: starts the Ollama daemon and generates agent configurations pointing to the local endpoint. |
| `programs.nixarchy.localAi.model` | `str` | `"qwen3:8b"` | Default Ollama model tag. Must be a tool-calling trained model (e.g. `qwen3:4b`, `qwen3:8b`, `qwen3:14b`). |
| `programs.nixarchy.localAi.agents` | `listOf str` | `[ "opencode" "pi" ]` | Coding agents that receive pre-configured provider profiles targeting the local Ollama instance. |
| `programs.nixarchy.localAi.acceleration` | `enum ["auto" "cuda" "rocm" "vulkan" "cpu"]` | `"auto"` | GPU compute backend for Ollama. `"auto"` inspects host hardware configuration. |
| `programs.nixarchy.localAi.allowCpu` | `bool` | `false` | Explicitly permits Ollama to fall back to CPU execution when no supported GPU is available. |
| `programs.nixarchy.localAi.contextWindow` | `nullOr int` | `null` | Context window size in tokens. Defaults to model/VRAM heuristics, but agents like `opencode` need `65536`. |
| `programs.nixarchy.localAi.host` | `str` | `"127.0.0.1"` | Listening IP address. Kept on loopback for security since Ollama provides no authentication layer. |
| `programs.nixarchy.localAi.port` | `port` | `11434` | TCP port for the local Ollama server. |
| `programs.nixarchy.localAi.modelsDir` | `nullOr str` | `null` | Storage directory for model weights. When `null`, defaults to `/var/lib/ollama/models`. Useful when `/` is small and models reside on a secondary partition. |
| `programs.nixarchy.localAi.hfHome` | `nullOr str` | `null` | Value exported as `HF_HOME` for user sessions, redirecting Hugging Face cache downloads away from `~/.cache/huggingface`. |
| `programs.nixarchy.localAi.pullModel` | `bool` | `false` | Automatically downloads the specified model during system activation rather than lazily on first run. Useful for unattended deployments. |

---

## 5. Services & System Infrastructure (`programs.nixarchy.services.*`)

Nixarchy differentiates between **Bundled Services** (which require specialized integrations, user session bindings, or systemd user units) and **Plain Services** (which are standard upstream NixOS modules that Nixarchy documents and exposes via template/companion files).

### Bundled vs. Plain Services Comparison

```
┌────────────────────────────────────────────────────────────────────────┐
│                        Nixarchy Services                               │
├───────────────────────────────────┬────────────────────────────────────┤
│ Bundled Nixarchy Services         │ Plain NixOS System Services        │
│ (`programs.nixarchy.services.*`)  │ (Configured via native NixOS options)
├───────────────────────────────────┼────────────────────────────────────┤
│ • devenv                          │ • services.openssh                 │
│ • microvm                         │ • virtualisation.podman            │
│ • open-webui                      │ • hardware.graphics.enable32Bit    │
│ • syncthing                       │ • virtualisation.waydroid          │
│ • tailscale                       │ • services.flatpak                 │
│ • boxes (distrobox runner)        │                                    │
└───────────────────────────────────┴────────────────────────────────────┘
```

### 1. Bundled Services (`programs.nixarchy.services.*`)

| Service Option | Type | Default | Integration Details |
|---|---|---|---|
| `programs.nixarchy.services.devenv.enable` | `bool` | `false` | Sets up per-project dev environments that activate upon `cd`. Configures shell hooks across Bash, Zsh, and Fish, and hooks into Nixarchy's binary cache. |
| `programs.nixarchy.services.microvm.enable` | `bool` | `false` | Installs `microvm.nix` tools and grants the desktop user membership in the `kvm` group, sharing the host's `/nix/store` read-only for instant sandbox boot times. |
| `programs.nixarchy.services.open-webui.enable` | `bool` | `false` | Browser UI for interacting with local models. Requires `programs.nixarchy.localAi.enable = true` and binds to `127.0.0.1:8080`. |
| `programs.nixarchy.services.syncthing.enable` | `bool` | `false` | Declarative folder synchronization. Configured automatically under `programs.nixarchy.user` so user permissions and home paths match without manual UID mapping. |
| `programs.nixarchy.services.tailscale.enable` | `bool` | `false` | Encrypted mesh VPN. Configures `tailscaled`, permits routing features, and adjusts the firewall to trust Tailscale virtual network interfaces (`tailscale0`). |
| `programs.nixarchy.services.boxes.enable` | `bool` | `false` | Distrobox container management, enabling rootless Podman and adding the Boxes management interface to the Omarchy launcher. |

### 2. Plain NixOS Companion Services

These services require no custom Nixarchy wrappers and are configured directly in your host's NixOS files (e.g. `hosts/laptop/nixarchy/services.nix` or `modules/common/`):

- **`services.openssh.enable = true;`**: Secure remote shell. NixOS defaults to key-based authentication with passwords disabled.
- **`virtualisation.podman.enable = true;`**: Rootless OCI containers, enabling Docker socket emulation and integration with the Omarchy Podman bar panel (`Super+Alt+O`).
- **`hardware.graphics.enable32Bit = true;`**: 32-bit graphics stack required by Steam, Wine, Proton, and retro game emulators.
- **`virtualisation.waydroid.enable = true;`**: Run Android applications directly on the Linux kernel with hardware acceleration. (Requires kernel binder support).
- **`services.flatpak.enable = true;`**: Opt-in runtime for sandboxed applications not yet packaged in `nixpkgs`.

---

<a id="applications-catalogue"></a>
## 6. Applications Catalogue (`programs.nixarchy.apps.*`)

Nixarchy includes a declarative catalogue of desktop applications (`programs.nixarchy.apps.<app>.*`). Each entry provides standard properties:
- **`enable`** (`bool`, default `false`): Enables the application on the system.
- **`package`** (`package`, default depends on app): Allows overriding the derivation (to pin specific versions, apply patches, or customize build flags).
- **`settings`** (`attrs`, default `{}`): Freeform attribute set merged directly into upstream NixOS configuration modules where applicable (e.g. `programs.firefox`, `programs._1password-gui`).

### AI Applications

| App Name | Option Attribute | Unfree? | Description & Integration |
|---|---|:---:|---|
| **Antigravity** | `apps.antigravity` | Yes | AI-assisted development tools and assistant. |
| **ChatGPT** | `apps.chatgpt` | Yes | Official desktop wrapper for OpenAI ChatGPT. |
| **Claude Code** | `apps.claude-code` | Yes | Anthropic's terminal-based coding assistant CLI. |
| **Codex** | `apps.codex` | No | Code completion and indexing tool. |
| **Dictation** | `apps.dictation` | No | Desktop voice dictation (Hold `F9` or `Super+Ctrl+X`). Downloads local Whisper models to user state storage. |
| **Gemini CLI** | `apps.gemini-cli` | No | Command-line client for Google Gemini models. |
| **HEY CLI** | `apps.hey-cli` | No | CLI quick-query assistant. |
| **LM Studio** | `apps.lm-studio` | Yes | GUI model catalog and local inference playground. |
| **Omarchy Voice** | `apps.omarchy-voice` | No | System voice control and desktop automation powered by Piper voice models and Whisper. |
| **OpenClaw** | `apps.openclaw` | No | Open-source automation crawler and extraction engine. |
| **OpenCode** | `apps.opencode` | No | Extensible AI coding agent harness with terminal/web UI. |
| **T3 Code** | `apps.t3-code` | No | Full-stack project scaffolding and maintenance agent. |

### Web Browsers

| App Name | Option Attribute | Unfree? | Description & Integration |
|---|---|:---:|---|
| **Brave** | `apps.brave` | No | Privacy-focused browser with ad-blocking. |
| **Chrome** | `apps.chrome` | Yes | Google Chrome proprietary browser. |
| **Edge** | `apps.edge` | Yes | Microsoft Edge browser. |
| **Firefox** | `apps.firefox` | No | Mozilla Firefox. Accepts `apps.firefox.settings` merged into `programs.firefox`. |
| **Zen** | `apps.zen` | No | Modern Firefox fork focused on privacy, speed, and vertical tabs. |

### Development Toolchains & Environments

| App Name | Option Attribute | Description & Integration |
|---|---|---|
| **Bun** | `apps.bun` | Fast all-in-one JavaScript/TypeScript runtime and bundler. |
| **Clojure** | `apps.clojure` | Clojure CLI tools and Leiningen build toolchain. |
| **Deno** | `apps.deno` | Modern secure JavaScript/TypeScript runtime. |
| **.NET** | `apps.dotnet` | Microsoft .NET SDK and runtime environment. |
| **Elixir** | `apps.elixir` | Elixir language and Mix build tool. |
| **Git LFS** | `apps.git-lfs` | System-wide Git Large File Storage filters (`apps.git-lfs.settings`). |
| **Go** | `apps.go` | The Go language compiler and toolchain. |
| **Java** | `apps.java` | OpenJDK runtime and compiler environment. |
| **Node.js** | `apps.nodejs` | Node.js runtime and npm package manager. |
| **OCaml** | `apps.ocaml` | OCaml compiler and opam toolchain. |
| **PHP** | `apps.php` | PHP interpreter and CLI. |
| **Python** | `apps.python` | Python 3 interpreter and standard distribution packages. |
| **Rust** | `apps.rust` | Rust compiler (`rustc`) and `cargo` package manager. |
| **Scala** | `apps.scala` | Scala programming language and SBT. |
| **Symfony** | `apps.symfony` | Symfony CLI framework tools (Unfree). |
| **uv** | `apps.uv` | Extremely fast Python package manager and resolver. |
| **Zig** | `apps.zig` | General-purpose programming language and toolchain. |

### Code Editors

| App Name | Option Attribute | Unfree? | Description & Integration |
|---|---|:---:|---|
| **Cursor** | `apps.cursor` | Yes | AI-first code editor based on VS Code. |
| **Emacs** | `apps.emacs` | No | GNU Emacs extensible editor. |
| **Helix** | `apps.helix` | No | Post-modern modal terminal editor with built-in Tree-sitter and LSP. |
| **Vim** | `apps.vim` | No | Traditional Vi IMproved text editor. |
| **VS Code** | `apps.vscode` | Yes | Visual Studio Code editor. |
| **Zed** | `apps.zed` | No | High-performance multiplayer code editor written in Rust. |

### Gaming

| App Name | Option Attribute | Unfree? | Description & Integration |
|---|---|:---:|---|
| **Heroic** | `apps.heroic` | No | Epic Games, GOG, and Amazon Games launcher. |
| **Lutris** | `apps.lutris` | No | Open gaming platform for managing Wine games and launchers. |
| **Minecraft** | `apps.minecraft` | Yes | Prism Launcher / Official Minecraft client. |
| **RetroArch** | `apps.retroarch` | No | Multi-system emulator frontend with standard libre cores. |
| **Steam** | `apps.steam` | Yes | Valve Steam gaming client (enables FHS environment). |
| **Xbox Controllers**| `apps.xbox-controllers` | No | Installs `xpadneo` / `xone` kernel drivers for wireless Xbox controller support. |

### Terminal Emulators

| App Name | Option Attribute | Description & Integration |
|---|---|---|
| **Alacritty** | `apps.alacritty` | Fast, GPU-accelerated terminal emulator written in Rust. |
| **Foot** | `apps.foot` | Lightweight, blazing fast Wayland-native terminal emulator. |
| **Ghostty** | `apps.ghostty` | Modern GPU-accelerated terminal with native Wayland features. |
| **Kitty** | `apps.kitty` | Feature-rich GPU terminal emulator with image support and remote control. |

### Services & Utilities

| App Name | Option Attribute | Unfree? | Description & Integration |
|---|---|:---:|---|
| **1Password** | `apps._1password` | Yes | GUI password manager. Configures polkit setuid helper via `apps._1password.settings`. |
| **Bitwarden** | `apps.bitwarden` | No | Open-source password manager desktop client. |
| **Dropbox** | `apps.dropbox` | Yes | Dropbox cloud storage client. |
| **NordVPN** | `apps.nordvpn` | Yes | NordVPN client daemon and CLI. |
| **Once** | `apps.once` | No | Lightweight disposable application runner. |
| **Signal** | `apps.signal` | No | Signal private messenger desktop app. |
| **Slack** | `apps.slack` | Yes | Slack team messaging platform. |
| **Spotify** | `apps.spotify` | Yes | Spotify music streaming client. |
| **Aether** | `apps.aether` | No | Peer-to-peer decentralized forum and news network. |
| **Android Tools**| `apps.android-tools` | No | Android platform tools (`adb`, `fastboot`) and udev rules. |
| **FreeRDP** | `apps.freerdp` | No | Remote Desktop Protocol (RDP) client for connecting to remote hosts. |
| **Omacalc** | `apps.omacalc` | No | Omarchy native desktop calculator utility. |
| **Omacut** | `apps.omacut` | No | Desktop screenshot and screen recording annotation utility. |
| **Omawrite** | `apps.omawrite` | No | Minimalist distraction-free Markdown notepad. |
| **Scrcpy** | `apps.scrcpy` | No | Display and control Android devices over USB or Wi-Fi. |

---

## 7. Dynamic Theme Engine (`programs.nixarchyThemeEngine.*`)

The **Nixarchy Theme Engine** (`hyprchroma` / `omarchroma`) propagates desktop theme and palette changes instantly across applications without requiring a `nixos-rebuild switch`.

### Stylix Integration Modes

The option `programs.nixarchyThemeEngine.stylix.mode` controls how the engine coordinates with the upstream [Stylix](https://github.com/danth/stylix) NixOS module:
- `"auto"` *(Default)*: Automatically activates Stylix bindings if `options.stylix` is present in the module graph; otherwise runs in standalone runtime mode.
- `"runtime"`: Ignores Stylix entirely and uses Omarchy's native dynamic hooks.
- `"stylix"`: Enforces Stylix presence and asserts an evaluation failure if the module is missing.

### Target Switches

You can toggle dynamic synchronization per application target:

```nix
programs.nixarchyThemeEngine = {
  enable = true;
  stylix.mode = "auto";
  targets = {
    gtk = true;             # Sync GTK 3/4 and GNOME schemas
    qtKde = true;           # Sync Qt 5/6 and KDE color schemes
    darkReader = true;      # Sync Dark Reader browser extensions
    pear = true;            # Sync Pear Desktop client
    flatpak = false;        # Sync Flatpak portal colors (opt-in)
    browsers = false;       # Sync Chromium/Brave/Edge profile tinting (opt-in)
    kitty = true;           # Send dynamic palette escape codes to Kitty
    foot = true;            # Write Foot theme includes
    ghostty = false;        # Disabled here: Repo manages Ghostty themes via home/ghostty/
    starship = true;        # Refresh Starship prompt palette
    bash = true;            # Inject runtime theme variables into Bash
    zsh = true;             # Inject runtime theme variables into Zsh
    fish = true;            # Inject runtime theme variables into Fish
    neovim = true;          # Feed live highlight groups into Neovim
    vim = true;             # Feed live highlight groups into classic Vim
  };
  electron.apps.vscode.enable = false; # VS Code workbench color synchronization
};
```

> **Repository Note**: In this configuration (`modules/desktop/nixarchy.nix`), `programs.nixarchyThemeEngine.targets.ghostty = false;` is set because Ghostty styling is maintained explicitly through user-level dotfiles in `home/ghostty/ghostty.config`.

---

## 8. Home Manager Integration & Plugins (`home-manager.users.<user>.programs.nixarchy.*`)

User-level configuration resides in `home/nixarchy/default.nix` and manages Omarchy Waybar/panel plugins, user menu data, and editor bindings.

### Options Table

| Option | Type | Default | Description |
|---|---|---|---|
| `programs.nixarchy.enable` | `bool` | `false` | Enables the Nixarchy user session module under Home Manager. |
| `programs.nixarchy.neovim` | `enum ["theme-only" "adopt" "off"]` | `"theme-only"` | Strategy for Omarchy's upstream Neovim configuration. Set to `"off"` in this repo to allow our dedicated LazyVim setup (`home/nvim/`) full ownership of `~/.config/nvim`. |
| `programs.nixarchy.neovimSpecs`| `attrsOf lines` | `{}` | LazyVim plugin specs declared as Nix strings, generated under `~/.config/nvim/lua/plugins/<name>.lua`. |
| `programs.nixarchy.defaultTheme`| `str` | `"tokyo-night"` | Palette applied upon initial user login before any runtime switches occur. |
| `programs.nixarchy.plugins.<id>.src` | `path` | `none` | Declares third-party or custom Omarchy shell plugins containing a valid `manifest.json`. Symlinked to `~/.config/omarchy/plugins/<id>`. |
| `programs.nixarchy.defaultPlugins.<name>` | `bool` | `true` | Toggles standard Nixarchy panel and status bar plugins. |

### Standard Plugins (`defaultPlugins`)

| Plugin Name | Purpose & Function | Repo Default |
|---|---|:---:|
| `pkg` | System package updates and search status bar widget. | `false` |
| `flatsnap` | Flatpak snapshot management. | `false` |
| `gitlab` | GitLab pipeline status monitor. | `false` |
| `github` | GitHub Actions workflow notification panel. | `true` |
| `herdr` | AI Agent flock monitor and orchestration panel. | `true` |
| `podman` | Rootless Podman container monitor (`Super+Alt+O`). | `false` |
| `distrobox` | Distrobox containers launcher and runner. | `false` |
| `microvm` | Declarative MicroVM sandbox controller. | `false` |
| `devenv` | Per-project dev environment switcher. | `true` |
| `plugin-browser` | Visual browser for discovering and installing panel plugins. | `true` |
| `omatheme` | Theme selection and preview widget. | `false` |
| `menu` | Nixarchy custom JSON application launcher menu. | `true` |

---

## 9. Fleet Management & Maintenance (`programs.nixarchy.fleet.*`, `autoUpdate`)

Nixarchy supports two independent, mutually exclusive GitOps automation workflows:

```
┌────────────────────────────────────────────────────────────────────────┐
│                      Fleet vs. Auto-Update                             │
├───────────────────────────────────┬────────────────────────────────────┤
│ Fleet (`fleet.*`)                 │ Auto-Update (`autoUpdate.*`)       │
├───────────────────────────────────┼────────────────────────────────────┤
│ • Designed for multi-machine sets │ • Designed for single workstations │
│ • Pulls from a REMOTE Git flake   │ • Rebuilds LOCAL flake in place    │
│ • Reverts unpushed local changes  │ • Only bumps `nixpkgs` input       │
│ • True centralized GitOps         │ • Preserves Nixarchy desktop pin   │
└───────────────────────────────────┴────────────────────────────────────┘
```

> **Evaluation Assertion**: Enabling both `fleet.enable = true` and `autoUpdate.enable = true` simultaneously will trigger an evaluation error to prevent conflicting rebuild timers.

### 1. Fleet Configuration (`programs.nixarchy.fleet.*`)

| Option | Type | Default | Description |
|---|---|---|---|
| `programs.nixarchy.fleet.enable` | `bool` | `false` | Enables remote GitOps pulling. Rebuilds the machine against a remote Git repository. |
| `programs.nixarchy.fleet.url` | `str` | `""` | The remote flake URL (e.g. `"github:myorg/nixos-fleet"`). Cannot be empty if enabled. |
| `programs.nixarchy.fleet.dates` | `str` | `"daily"` | systemd calendar string specifying when to pull and switch (e.g. `"04:00"`). Includes automatic randomized jitter. |

### 2. Standalone Auto-Updates (`programs.nixarchy.autoUpdate.*`)

| Option | Type | Default | Description |
|---|---|---|---|
| `programs.nixarchy.autoUpdate.enable` | `bool` | `false` | Updates the machine's local `nixpkgs` flake input on a timer and rebuilds the system. Leaves the `nixarchy` input untouched to prevent surprise desktop UI changes. |
| `programs.nixarchy.autoUpdate.allowDirty`| `bool` | `false` | When `false`, the update unit safely aborts if the local flake git directory contains uncommitted changes. |
| `programs.nixarchy.autoUpdate.dates` | `str` | `"daily"` | systemd calendar interval for performing the automated update. |

---

## 10. Common Recipes & Examples

### Recipe 1: Enabling Local AI with CUDA on an NVIDIA Laptop
Add this to your host configuration (e.g., `hosts/laptop/default.nix` or `hosts/laptop/nixarchy/services.nix`):

```nix
{ config, pkgs, ... }: {
  programs.nixarchy.localAi = {
    enable = true;
    acceleration = "cuda";
    model = "qwen3:8b";
    contextWindow = 65536; # Recommended for opencode and coding agents
    pullModel = true;      # Fetch automatically on deployment
    agents = [ "opencode" "claude-code" ];
  };

  # Open WebUI chat frontend (optional)
  programs.nixarchy.services.open-webui.enable = true;
}
```

---

### Recipe 2: Adding Custom Apps with Settings Overrides
In `hosts/laptop/nixarchy/apps.nix`:

```nix
{ pkgs, ... }: {
  programs.nixarchy.apps = {
    # Enable Spotify and Obsidian
    spotify.enable = true;
    obsidian.enable = true;

    # Override package with specific core plugins
    retroarch = {
      enable = true;
      package = pkgs.retroarch.withCores (cores: with cores; [
        snes9x
        mame
        genesis-plus-gx
      ]);
    };

    # Declaratively configure Firefox policies and extensions
    firefox = {
      enable = true;
      settings = {
        policies = {
          DisableTelemetry = true;
          DisableFirefoxStudies = true;
          ExtensionSettings = {
            "uBlock0@raymondhill.net" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
              installation_mode = "force_installed";
            };
          };
        };
      };
    };
  };
}
```

---

### Recipe 3: Disabling Theme Engine for Specific Tools
If you prefer a manual, fixed configuration for your terminal emulator and shell prompt while keeping dynamic theming for GTK and Qt:

```nix
# In modules/desktop/nixarchy.nix
{
  programs.nixarchyThemeEngine.targets = {
    ghostty = false;   # Let ~/.config/ghostty/config control colors
    starship = false;  # Preserve custom starship.toml palette
    neovim = false;    # Neovim highlights managed by your own init.lua
  };
}
```

---

### Recipe 4: Declaring Custom Panel Plugins & Managing Defaults
In `home/nixarchy/default.nix`:

```nix
{ pkgs, ... }: {
  # Selectively disable default widgets and enable specific ones
  programs.nixarchy.defaultPlugins = {
    pkg = false;
    podman = false;
    github = true;
    herdr = true;
    devenv = true;
    menu = true;
  };

  # Declare a custom Omarchy plugin from a Git repo
  programs.nixarchy.plugins.custom-teleprompter = {
    src = pkgs.fetchFromGitHub {
      owner = "custom-user";
      repo = "omarchy-teleprompter";
      rev = "v1.2.0";
      hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
    };
  };
}
```

---

### Recipe 5: Enabling Sandboxed MicroVMs
In `hosts/laptop/nixarchy/services.nix`:

```nix
{ ... }: {
  programs.nixarchy.services.microvm.enable = true;
  # Desktop user now has KVM access and MicroVM CLI tools for running
  # lightweight, ephemeral NixOS sandbox instances sharing the host /nix/store.
}
```
