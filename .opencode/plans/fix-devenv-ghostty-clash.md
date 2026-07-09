# Fix: devenv `undefined symbol: ghostty_cell_get`

## Root cause
`home/zsh/default.nix` (lines 29-33) sets `LD_LIBRARY_PATH=/etc/profiles/per-user/nic/lib`
globally in every interactive shell. That dir mixes in `libghostty-vt.so.0.1.0` (from the
installed Ghostty home-manager package), which is an OLDER build that lacks the
`ghostty_cell_get` symbol. devenv 2.1.2 bundles its OWN newer libghostty-vt
(`/nix/store/zc2hb72...-libghostty-vt-0.1.0-unstable-2026-05-03`) which has the symbol — but the
dynamic loader consults `LD_LIBRARY_PATH` first, so devenv loads the stale profile copy and
crashes on startup.

Proof: `env -u LD_LIBRARY_PATH devenv --version` -> `devenv 2.1.2 (x86_64-linux)` (works).

## Why the global path exists
Only mise-installed Temurin Java needs it. Its `libawt_xawt.so` / `libjawt.so` /
`libsplashscreen.so` link `libX11.so.6`, `libXext.so.6`, `libXi.so.6`, `libXrender.so.1`,
`libXtst.so.6`. Java has no Nix RUNPATH, so it must find these via `LD_LIBRARY_PATH`.
All other mise-installed tools (node, go, rust, zig, goreleaser, act, etc.) had ZERO missing
libs without `LD_LIBRARY_PATH`. `libasound.so.2` (for `libjsound.so` / Java audio) is NOT in
the profile dir anyway, so audio is already broken regardless of this change.

## Fix
Replace the broad profile-lib path with a Nix `buildEnv` containing ONLY the 5 X11 libs Java
needs. This removes ghostty/gtk-4/mpv/python/nautilus contamination (good hygiene — none of
those should be globally on the linker path) while keeping Java working.

### Edit `home/zsh/default.nix`

Replace the file header (lines 1-33) — current:

```nix
{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    fzf
  ];

  programs.zsh = {
    ...
    initContent = ''
      export MANPATH="/usr/local/man:$MANPATH"
      export LANG=en_US.UTF-8
      if [[ -n $SSH_CONNECTION ]]; then
          export EDITOR='vim'
      else
          export EDITOR='nvim'
      fi
      export JDTLS_JVM_ARGS="-javaagent:$HOME/.config/nvim/lib/lombok.jar"
      if [ -n "$LD_LIBRARY_PATH" ]; then
          export LD_LIBRARY_PATH="/etc/profiles/per-user/nic/lib:$LD_LIBRARY_PATH"
      else
          export LD_LIBRARY_PATH="/etc/profiles/per-user/nic/lib"
      fi
```

With:

```nix
{
  config,
  pkgs,
  ...
}: let
  javaRuntimeLibs = pkgs.buildEnv {
    name = "java-runtime-libs";
    paths = with pkgs.xorg; [libX11 libXext libXi libXrender libXtst];
    pathsToLink = ["/lib"];
  };
in {
  home.packages = with pkgs; [
    fzf
  ];

  programs.zsh = {
    ...
    initContent = ''
      export MANPATH="/usr/local/man:$MANPATH"
      export LANG=en_US.UTF-8
      if [[ -n $SSH_CONNECTION ]]; then
          export EDITOR='vim'
      else
          export EDITOR='nvim'
      fi
      export JDTLS_JVM_ARGS="-javaagent:$HOME/.config/nvim/lib/lombok.jar"
      export LD_LIBRARY_PATH="${javaRuntimeLibs}/lib''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
```

(Only the `let ... in` header and the `LD_LIBRARY_PATH` export line change. The rest of
`initContent` below line 33 — `GEMINI_API_KEY`, `homes.sh`, the `for f` loop, `fzf --zsh` —
is untouched.)

### Verify
1. `mise run format`
2. `mise run build laptop`
3. After switching (user-driven, on laptop): in a fresh shell run
   - `devenv --version` -> should print `devenv 2.1.2 (x86_64-linux)`
   - `java -version` -> should print Temurin version (GUI/on-X still works)
   - `echo $LD_LIBRARY_PATH` -> should be a single `/nix/store/...-java-runtime-libs/lib`
     entry, not the old `/etc/profiles/per-user/nic/lib` directory.

### Notes / non-regressions
- `libasound` (Java audio) was never on the path; unchanged.
- If Java audio is desired later, add `pkgs.alsa-lib` to `javaRuntimeLibs.paths`.
- If Java AWT shows any other missing X lib after the switch, add it to the same `paths`
  list — the buildEnv is the single source of truth.
- Server hosts (dobby, rpi) don't import `home/zsh/default.nix` (they use `home/server.nix`),
  so this change does not affect them.

## Status
AWAITING USER APPROVAL to exit plan mode and apply.