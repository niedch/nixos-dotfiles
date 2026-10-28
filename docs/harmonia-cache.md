# Harmonia binary cache

Dobby runs [harmonia](https://github.com/nix-community/harmonia) as a lightweight binary cache daemon on port `5000`. It serves dobby's local `/nix/store` directly over HTTP, allowing other machines on the local network (such as laptops and desktops) to pull pre-built store paths instead of building them locally.

## Architecture

Unlike setups that maintain a secondary chroot store, Harmonia directly shares dobby's primary system Nix store:

| Component | Path / Configuration | Purpose |
|-----------|----------------------|---------|
| **Service** | `modules/server/nix-cache.nix` | Runs Harmonia on port 5000, serving `/nix/store` signed by SOPS secret |
| **Builder Workflow** | `.github/workflows/cache-pr.yaml` | Builds all host toplevels on `master` pushes directly into the local store |
| **GC Roots** | `/nix/var/nix/profiles/per-user/runner/` | Per-host profile links registered by the runner to prevent premature GC |
| **Garbage Collection** | `modules/common/nix-gc.nix` | Standard daily system GC with `--delete-older-than 5d` |
| **Client Config** | `modules/common/cache-config.nix` | Configures substituters and trusted public keys on all nodes |

### Key Architectural Advantages
- **Single store**: Harmonia reads `/nix/var/nix/db/db.sqlite` directly. There is no isolated SQLite DB to initialize or corrupt.
- **Zero copy overhead**: Pre-built closures are already in `/nix/store`; no `nix copy` step is required between stores.
- **Complete closures**: Building directly into the local store preserves both runtime closures and all build-time derivation dependencies needed for system activations.

---

## Cache Population

The cache is automatically populated by the self-hosted GitHub Actions runner running on dobby:

1. **Trigger**: When changes merge into `master`, `.github/workflows/cache-pr.yaml` runs on the `[self-hosted, nix, harmonia]` runner.
2. **Build command**: The runner builds the system toplevel for each matrix host (`laptop`, `raspberry-pi`, `dobby`, `desktop`) with an explicit `--profile` flag:

   ```bash
   nix build ".#nixosConfigurations.${{ matrix.host }}.config.system.build.toplevel" \
     --print-out-paths \
     --profile "/nix/var/nix/profiles/per-user/runner/cache-${{ matrix.host }}" \
     --accept-flake-config --fallback
   ```

3. **GC roots**: Pointing `--profile` to `/nix/var/nix/profiles/per-user/runner/cache-<host>` creates versioned profile generations (e.g. `cache-laptop-1-link`, `cache-laptop-2-link`). These symlinks act as active Nix GC roots, ensuring recent builds stay in the store.
4. **Runner permissions**: `modules/server/github-runner.nix` grants the runner write access to `/nix/var/nix/profiles/per-user/runner` via systemd `ReadWritePaths` and a `systemd.tmpfiles` rule.

---

## Garbage Collection

Cache retention and cleanup are completely managed by standard NixOS garbage collection via `modules/common/nix-gc.nix`:

- **Automatic schedule**: Runs daily via `nix.gc.automatic = true` and `options = "--delete-older-than 5d"`.
- **Profile pruning**: When `nix-collect-garbage --delete-older-than 5d` runs, it prunes runner profile generations older than 5 days in `/nix/var/nix/profiles/per-user/runner/`.
- **Store path collection**: Store paths referenced only by deleted profile generations are automatically reclaimed. Store paths referenced by recent generations (or the active systems) are preserved.
- **Notifications**: Message board notifications (`/run/current-system/sw/bin/post-homepage-message-board`) report GC start, completion, or failure to the dashboard.

No separate GC scripts or auxiliary store GC roots are required.

---

## Client Configuration

Client hosts consume the cache through `modules/common/cache-config.nix`, which is imported by all systems via `modules/common/default.nix`:

```nix
{ config, ... }:
{
  nix.settings = {
    substituters = [
      "http://dobby:5000"
      "https://cache.nixos.org"
      "https://nixarchy.cachix.org"
      "https://hyprland.cachix.org"
    ];
    trusted-public-keys = [
      # Harmonia public key configured on dobby:
      "dobby:rrZQzoRX5Glj/0fX+bFGJ6YUPoxb3z/hg5K84k2G8yo="
      "nixarchy.cachix.org-1:05JOuIlsQOWY2/5DQMq7JEA1hwlhgvmMWowMfka8mMM="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIITemDosxrE9/Kb+PfYvE="
    ];
  };
}
```

*Note: On dobby itself, the local runner queries `http://127.0.0.1:5000` (configured in `modules/server/github-runner.nix`). Harmonia serves with `priority = 30` (configured in `modules/server/nix-cache.nix`), prioritizing dobby over upstream `cache.nixos.org` (priority 40).*

> **Requirement for cache hits**: Clients only hit the cache when their flake inputs and configurations match what the runner built on `master`. Keep client repositories in sync with `master`.

---

## Verification Commands

### 1. Verify Harmonia responds
On dobby:
```bash
curl -i http://127.0.0.1:5000/nix-cache-info
```

From another host on the LAN:
```bash
curl -i http://dobby:5000/nix-cache-info
```

Expected response (`200 OK`):
```text
HTTP/1.1 200 OK
content-type: text/x-nix-cache-info
...
StoreDir: /nix/store
WantMassQuery: 1
Priority: 30
```

### 2. Verify `narinfo` lookup for a cached path
Find a store path hash from one of the runner's profile symlinks on dobby:
```bash
# Get the full target store path:
STORE_PATH=$(readlink -f /nix/var/nix/profiles/per-user/runner/cache-laptop)
HASH=$(basename "$STORE_PATH" | cut -d'-' -f1)

# Check narinfo response:
curl -i "http://dobby:5000/$HASH.narinfo"
```
Harmonia will return `200 OK` with store path metadata and its cryptographic signature (`Sig: ...`).

### 3. Check runner profile generations and GC roots
Inspect current profiles registered by the runner:
```bash
ls -la /nix/var/nix/profiles/per-user/runner/
nix-env -p /nix/var/nix/profiles/per-user/runner/cache-laptop --list-generations
```

### 4. Metrics & Monitoring
Harmonia exposes Prometheus metrics consumed by the Glance dashboard:
```bash
curl -s http://127.0.0.1:5000/metrics | grep harmonia
```

---

## One-Time Cleanup (Legacy Chroot Store)

The previous cache architecture stored paths in a separate chroot store at `/mnt/hdd/nix`. If this directory is still present on dobby, it is now obsolete and safe to delete to reclaim disk space:

```bash
sudo rm -rf /mnt/hdd/nix
```
