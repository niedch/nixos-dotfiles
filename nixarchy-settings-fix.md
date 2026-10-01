# Fix: nixarchy-menu config in the nix-store (read-only) vs. runtime writes

Status: draft plan
Scope: nixarchy-menu (upstream or fork) + the `home/nixarchy` dotfiles in this repo

## Problem

`nixarchy-menu` keeps its settings in a single JSON file, hardcoded to
`~/.config/omarchy/nixarchy-menu.json` in `NixarchyMenu.qml`:

```qml
readonly property string configPath: home + "/.config/omarchy/nixarchy-menu.json"
```

These dotfiles declare that file through Home Manager:

```nix
# home/nixarchy/default.nix
xdg.configFile."omarchy/nixarchy-menu.json".source = ./nixarchy-menu.json;
```

`xdg.configFile` installs it as a **read-only symlink into the nix-store**.
nixarchy-menu writes to it in two places (see "Current behaviour"), and both
use a `FileView` with `atomicWrites: true` (temp file + rename). A rename
replaces the *directory entry* — the symlink — with a plain writable file, so:

- the store-managed file is silently detached (the store copy stops being
  authoritative), and
- the next `home-manager switch` re-creates the symlink and **wipes the
  runtime edits**.

The requested feature: let the store file be a small **pointer** that names
where the real (writable) config lives, e.g.:

```json
{ "version": 1, "configFile": "/home/nic/.local/state/nixarchy-menu/config.json" }
```

## Current behaviour (evidence)

All in `NixarchyMenu.qml` unless noted.

1. **Path** — `configPath` is fixed to `$HOME/.config/omarchy/nixarchy-menu.json`.
2. **Load** — one `FileView { id: configFile }` reads it:
   - `onLoaded` → `applyConfigText(text())` then `configSettled = true`
   - `onLoadFailed` → `applyConfigText("")` then `configSettled = true`
   - `watchChanges: true`, `atomicWrites: true`
3. **Write site A** (settings change) — `perform()` on `action.type === "setting"`
   calls `saveConfig(Settings.withValue(...))`. `saveConfig` guards on
   `configSettled` / `configError`, then `configFile.setText(...)`.
4. **Write site B** ("Open config file") — `action.type === "edit"` does
   `configFile.setText(Settings.serialize(root.config))` then
   `xdg-open root.configPath`.
5. **Gating** — the `migrateState` process (`helpers/migrate-state.sh`) sets
   `stateReady`; on failure `configSettled = true` and defaults apply. All
   reads/writes are no-ops until `stateReady`.
6. **Settings UI** — the "Open config file" row shows `model.configPath`
   (`providers/SettingsProvider.qml` → `model()` → `configPath: h.configPath`;
   rendered by `core/SettingsTree.js` `build()`).

`core/Settings.js` `parse()` tolerates and **preserves** unknown top-level
fields (it returns the raw object), so an extra `configFile` key needs no
version bump and no schema change.

## Options

1. **Pointer field (recommended)** — add `configFile` support to nixarchy-menu.
   The store file is a pointer; the real config is a writable file. Keeps the
   store path as the entry point and matches the existing
   `~/.local/state/nixarchy-menu/` convention (`usage.json` already lives there).
2. **Seed, don't manage (no code change)** — drop the `xdg.configFile` and
   instead copy `./nixarchy-menu.json` to `~/.config/omarchy/nixarchy-menu.json`
   once on activation (only if absent); the plugin owns it afterwards. This is
   exactly how nixarchy already handles `voxtype/config.toml`, `tensaku`, and
   the branding files (the host's `seed_file` convention). Downside: later
   edits to the repo file no longer propagate; the file stops being
   "declarative" after the first run.
3. **Env-var override** — read `NIXARCHY_MENU_CONFIG` at load. Minimal, but it
   only moves *where*, and does not layer declarative + writable.

Recommendation: **(1) pointer field**, with the real config **seeded** once
into `~/.local/state/nixarchy-menu/config.json` so existing settings survive
the first run (see Dotfiles).

## Implementation — nixarchy-menu

Field: top-level `configFile` (string; absolute path, `~/` expanded against
`$HOME`). Present + non-empty + different from `configPath` ⇒ relocate.
Absent ⇒ unchanged legacy behaviour.

### NixarchyMenu.qml

1. Add next to `configPath`:

```qml
// Effective config path: the pointer target when the primary file carries
// `configFile`, otherwise the primary path itself.
property string resolvedConfigPath: ""
```

2. Add a second `FileView` for the real file:

```qml
FileView {
    id: realConfigFile
    path: ""
    watchChanges: true
    atomicWrites: true
    printErrors: false
    onLoaded: { root.applyConfigText(text()); root.configSettled = true }
    onLoadFailed: { root.applyConfigText(""); root.configSettled = true }
    onFileChanged: reload()
}
```

3. Change the primary `configFile` `onLoaded` to resolve the pointer first:

```qml
onLoaded: {
    var primary = Settings.parse(text())
    var ptr = primary.config && typeof primary.config.configFile === "string"
        ? String(primary.config.configFile).replace(/^~\//, root.home + "/") : ""
    if (ptr && ptr !== root.configPath) {
        root.resolvedConfigPath = ptr
        realConfigFile.path = ptr        // real-file load sets configSettled
    } else {
        root.resolvedConfigPath = root.configPath
        root.applyConfigText(text())
        root.configSettled = true
    }
}
```

(`onLoadFailed` stays as today — no pointer, defaults, settled.)

4. Add one write helper and route both writers through it:

```qml
function writeConfig(text) {
    if (root.resolvedConfigPath && root.resolvedConfigPath !== root.configPath)
        realConfigFile.setText(text)
    else
        configFile.setText(text)
}
```

- `saveConfig`: replace `configFile.setText(...)` with `root.writeConfig(...)`.
- `edit` action: replace `configFile.setText(...)` with `root.writeConfig(...)`
  and `xdg-open root.configPath` with `xdg-open root.resolvedConfigPath`.

5. `resolvedConfigPath` is set on primary load, and `saveConfig` already
   refuses before `configSettled`, so no change to the `migrateState` gating.
   The pointer target's parent directory must already exist; the
   `migrate-state.sh` script already creates `~/.local/state/nixarchy-menu/`.

### providers/SettingsProvider.qml

`model()` returns `configPath: h.configPath`. Change to the resolved path so
the "Open config file" row shows the real file:

```js
configPath: h.resolvedConfigPath || h.configPath
```

(`core/SettingsTree.js` needs no change — it already renders `model.configPath`.)

### core/Settings.js

No change required (unknown top-level fields are preserved; no version bump).
Optionally document `configFile` alongside the example schema.

### Tests

- Extend the config-settle tests (`tests/palette_config_settle_check.py` and the
  QML suite) with:
  - pointer present → loads the real file; `configSettled` true only after the
    real file loads.
  - pointer present + real file missing → defaults, then the first save
    creates it.
  - pointer absent → legacy behaviour unchanged.
  - pointer equal to `configPath` itself → treated as no pointer (no loop).
- A round-trip: a settings change writes to the real file and never touches the
  pointer file.

## Implementation — dotfiles

`home/nixarchy/default.nix`:

- Keep `xdg.configFile."omarchy/nixarchy-menu.json"` pointing at the new
  pointer file (store-managed, read-only — fine, it is never written).
- Add a one-time seed of the real config (Home Manager `activationScript` or
  the host `seed_file` convention) so the current settings in
  `home/nixarchy/nixarchy-menu.json` become the initial
  `~/.local/state/nixarchy-menu/config.json` **only if absent**.

`home/nixarchy/nixarchy-menu.json` becomes the pointer:

```json
{ "version": 1, "configFile": "/home/nic/.local/state/nixarchy-menu/config.json" }
```

## Rollout / verification

1. Apply the nixarchy-menu patch (fork or upstream PR).
2. Rebuild the dotfiles; confirm `~/.config/omarchy/nixarchy-menu.json` is a
   store symlink containing the pointer, and
   `~/.local/state/nixarchy-menu/config.json` was seeded once.
3. Open Settings, change a setting, and confirm:
   - the pointer file is untouched (still a symlink),
   - the real file was written,
   - the change survives `home-manager switch`.
4. `bin/nixarchy-menu test` (inside `nix develop`) passes.

## Open decisions

- Field name: `configFile` vs `configPath` vs `source`.
- Whether the pointer file may also carry **defaults** used when the real file
  is absent (would avoid a separate seed step) — deferred; the seed step is
  simpler and matches nixarchy's existing `seed_file` convention.
- Absolute vs relative vs `~` paths (the plan assumes absolute, expands `~/`).