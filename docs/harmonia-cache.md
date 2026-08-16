# Harmonia binary cache

Dobby runs [harmonia](https://github.com/nix-community/harmonia) as a binary
cache on port `5000`. Other hosts pull from it via `http://dobby:5000`
(configured in `modules/common/cache-config.nix`).

## Architecture

The cache is a **separate Nix store** from dobby's own `/nix/store`. It lives
on the HDD at `/mnt/hdd/nix` (a "chroot" store, i.e. `--store /mnt/hdd/nix`).

| Path | Purpose |
|------|---------|
| `/mnt/hdd/nix/nix/store/` | Store paths served to clients |
| `/mnt/hdd/nix/nix/var/nix/db/db.sqlite` | SQLite DB harmonia reads for narinfo metadata |
| `/mnt/hdd/nix/nix/var/nix/gcroots/auto/cache-keep` | GC roots written by `nix-cache-gc` |

- `modules/server/nix-cache.nix` — harmonia service (`real_nix_store = "/mnt/hdd/nix/nix/store"`).
- `.github/workflows/cache-pr.yaml` — on push to `master`, the self-hosted runner builds each host and populates the cache with `nix copy --to /mnt/hdd/nix`.
- `modules/server/nix-gc-cache.nix` — daily GC of the cache store.

## Gotcha: never use `file://` for the copy target

`nix copy --to file:///mnt/hdd/nix` writes a **binary-cache directory**
(`nix-cache-info`, `*.narinfo`, `nar/`), not a real store. Harmonia cannot
serve that — it needs a real store with a SQLite DB. Use a bare path
(`nix copy --to /mnt/hdd/nix`), which populates a real chroot store.

Harmonia auto-derives `nix_db_path` from `real_nix_store` by replacing the
trailing `store` with `var/nix/db/db.sqlite`. So `real_nix_store` must be
`/mnt/hdd/nix/nix/store` (one `nix/` level deeper than the old, wrong
`/mnt/hdd/nix/store`).

## Gotcha: copy the build closure too

`nix copy --to /mnt/hdd/nix ".#<host>.config.system.build.toplevel"` copies only the
*runtime* closure. A handful of system activation/generation scripts (`activate`,
`dry-activate`, `stage-2-init.sh`, `extra-udev-rules`, `boot.json`,
`ensure-all-wrappers-paths-exist`) are *build-time* inputs to the toplevel, so they
would be missing and Nix would rebuild the activation subgraph locally. Pair the
runtime copy with a derivation copy:

    nix copy --to /mnt/hdd/nix --derivation ".#<host>.config.system.build.toplevel"

The workflow does both.

## Recovery steps (populate cache, then switch)

> Order matters: harmonia refuses to start if its `db.sqlite` does not exist
> yet, so populate the cache **before** switching dobby.

1. **Wipe stale binary-cache artifacts** (frees `nar/` blobs; keeps the dir and
   its `nixbld`-writable ownership so the runner can still write):

   ```bash
   sudo find /mnt/hdd/nix -mindepth 1 -delete
   ```

2. **Commit and push** the fix to `master`. This triggers `cache-pr.yaml` on
   the runner, which builds all hosts and copies each closure into
   `/mnt/hdd/nix` as a real chroot store.

3. **After the workflow finishes**, switch dobby:

   ```bash
   mise run switch dobby
   ```

4. **Verify** harmonia serves the cache (expect `200`, not `404`/`000`):

   ```bash
   # on dobby:
   curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:5000/nix-cache-info

   # from another host (e.g. the laptop), use the hostname instead of 127.0.0.1:
   curl -s -o /dev/null -w '%{http_code}\n' http://dobby:5000/nix-cache-info

   # probe a real store path — substitute an actual hash from /mnt/hdd/nix/nix/store:
   curl -s -o /dev/null -w '%{http_code}\n' http://dobby:5000/HASH.narinfo
   ```

## Notes

- Cache hits only occur when a client's flake inputs + config exactly match
  what the runner built on `master`. Keep clients in sync with `master`.
- If the workflow's `nix copy` errors with an init failure, add an explicit
  `nix store init --store /mnt/hdd/nix` step before the copy.
