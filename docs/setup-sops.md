# SOPS key setup for a host

This covers adding a host's age key to the SOPS-encrypted `secrets/secrets.yaml`.
For the flake registration steps (creating `hosts/<name>/`, adding it to
`flake.nix`, rebuilding), see "Adding a host" in `AGENTS.md`.

## Prerequisites

- The host imports `modules/common` (which pulls in `modules/common/sops.nix`).
- An ed25519 SSH key exists on the host at the path the sops module reads:
  - **Servers** — `/etc/ssh/ssh_host_ed25519_key` (system-level `sshKeyPaths`)
  - **Desktop/laptop** — `~/.ssh/id_ed25519` (user-level; converted to age at
    `sops.age.keyFile = /home/nic/.config/sops/age/keys.txt`)
- An already-authorized machine that can decrypt `secrets/secrets.yaml`.

## 1. Enable OpenSSH

Ensure the host imports `modules/common` (or `modules/server/openssh.nix`
directly), then rebuild:

```bash
mise run switch <host>
```

For a new host that doesn't have a proper config yet, you can start sshd
temporarily with a nix-shell:

```bash
nix shell nixpkgs#openssh
sshd
passwd
```

## 2. Generate the private age key from the SSH key

Run this on the new host. For servers (SSH host key):

```bash
nix shell nixpkgs#ssh-to-age
sudo ssh-to-age -private-key -i /etc/ssh/ssh_host_ed25519_key \
  > /home/nic/.config/sops/age/keys.txt
sudo chown nic:users /home/nic/.config/sops/age/keys.txt
chmod 600 /home/nic/.config/sops/age/keys.txt
```

For desktop/laptop (user key):

```bash
nix shell nixpkgs#ssh-to-age
ssh-to-age -private-key -i ~/.ssh/id_ed25519 \
  > ~/.config/sops/age/keys.txt
chmod 600 ~/.config/sops/age/keys.txt
```

## 3. Generate the public key

```bash
nix shell nixpkgs#age
age-keygen -y ~/.config/sops/age/keys.txt
```

This prints an `age1...` public key.

## 4. Add the key to `.sops.yaml`

Add a new entry in the `keys:` list and reference it in `creation_rules`:

```yaml
keys:
  - &admin_nic age1jamvvkqedtd5x2gx72723k5ad77zmqxvgy42e3l0quvf7n9dgdgsj66a6g
  - &host_laptop age1z4mv8yv6xaht54e9a4ryyg4z6dvf26ngz4zdtvn62mrxp2ewuadqlnc8dz
  - &host_vm    age16q0t68ehuldfkmqte2kpa9pj4hpjdh05fnczqr0wgrzqy4up8swq74ar8g
  - &host_rpi   age1zpq27cmrclffrh6jyuxnnfwtafuqvdgl7tartcdystgzxm6eue7sgatuyr
  - &host_<name> age1...   # <-- new

creation_rules:
  - path_regex: ^secrets/secrets\.yaml$
    key_groups:
      - age:
          - *admin_nic
          - *host_laptop
          - *host_vm
          - *host_rpi
          - *host_<name>  # <-- new
```

## 5. Re-encrypt secrets

On the already-authorized machine with a valid decryption key:

```bash
nix shell nixpkgs#sops
sops updatekeys secrets/secrets.yaml
```

Commit both `.sops.yaml` and `secrets/secrets.yaml` together:

```bash
git add .sops.yaml secrets/secrets.yaml
git commit -m "secrets: add age key for <host>"
```

## 6. Validate on the new machine

Push the repo to the new host (or clone it), then:

```bash
nix shell nixpkgs#sops
sops -d secrets/secrets.yaml > /dev/null
```

If it exits with code 0 (no output), decryption works. You can also inspect
a specific secret:

```bash
sops -d secrets/secrets.yaml | jq '.<secret_name>'
```

## Troubleshooting

| Problem | Likely cause | Fix |
|---------|-------------|-----|
| `sops -d` hangs or asks for a passphrase | No private key found at the configured path | Verify `keys.txt` exists and is readable |
| `Error: age identity not found` | The `keys.txt` was generated from a different SSH key | Re-run step 2 using the *exact* SSH key that the sops module reads (check `sshKeyPaths` or `keyFile` in the config) |
| `Error: file is not age encrypted` | File not re-keyed after adding the new recipient | Run `sops updatekeys` on an authorized machine (step 5) |
| `Permission denied` on `/etc/ssh/ssh_host_ed25519_key` | Server host keys are root-only | Use `sudo` in step 2 |

## Key path reference

| Host type | sops module config | Private key source | age file location |
|-----------|-------------------|-------------------|-------------------|
| Servers (dobby, rpi) | `sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"]` | SSH host key | `/home/nic/.config/sops/age/keys.txt` |
| Desktop / laptop | `keyFile = "/home/nic/.config/sops/age/keys.txt"` (home-manager override) | `~/.ssh/id_ed25519` | `~/.config/sops/age/keys.txt` |
