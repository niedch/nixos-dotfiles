# Raspberry Pi NixOS setup

This documents the initial setup of a Raspberry Pi (aarch64) with NixOS using the
[Eisfunke guide](https://www.eisfunke.com/posts/2023/nixos-on-raspberry-pi.html)
approach: build the closure on an x86 build machine via QEMU binfmt emulation,
copy it to the Pi, and activate remotely.

**Host references in this repo:**
- **Build machine** — your x86 PC (e.g. `desktop` or `laptop`)
- **Target** — `raspberry-pi` (hostname `rpi`)

## Prerequisites

- Raspberry Pi (3B/4/5 tested)
- SD card (8 GB+)
- SD card reader
- Ethernet cable (easiest) or WiFi
- HDMI cable + keyboard (for initial setup)
- Build machine with Nix (this repo's flake)

## 1. Flash the SD image

Download the latest aarch64 SD image from Hydra:

```bash
nix-shell -p wget zstd
```

Browse to the [latest successful build](https://hydra.nixos.org/job/nixos/trunk-combined/nixos.sd_image.aarch64-linux)
and copy the link to the build product `.img.zst`. Then:

```bash
wget <image-url>
unzstd -d nixos-sd-image-*.img.zst
dmesg --follow
```

Insert your SD card, find its device (e.g. `/dev/sdX`), then flash:

```bash
sudo dd if=nixos-sd-image-*.img of=/dev/sdX bs=4096 conv=fsync status=progress
```

## 2. First boot — enable SSH

Insert the SD card into the Pi and power it on with HDMI + keyboard attached.
You'll be dropped into a root shell.

### Get networking

**Ethernet** — plug in; DHCP should work automatically.

**WiFi** — find your interface (`ip link`, usually `wlan0`):

```bash
wpa_supplicant -B -i wlan0 -c <(wpa_passphrase 'SSID' 'passphrase')
ip addr add 192.168.1.X/24 dev wlan0
ip route add default via 192.168.1.1
nix-shell -p dhcpcd
dhcpcd wlan0
```

### Enable SSH temporarily

Use `nix-shell` to get an SSH server running immediately (no rebuild needed):

```bash
nix-shell -p openssh
sshd
```

Set a root password so you can SSH in:

```bash
passwd
```

Find your Pi's IP:

```bash
ip addr | grep inet
```

Then from your build machine, copy the generated config files and SSH in:

```bash
scp root@<pi-ip>:/etc/nixos/hardware-configuration.nix .
nix copy <store-path> --to ssh://root@<pi-ip>
# ... proceed with activation
```

> The ad-hoc `sshd` session is ephemeral — after reboot the Pi goes back to
> the stock SD image config. That's fine; `switch-to-configuration` (step 7)
> makes the new system permanent.

## 3. On your build machine — add binfmt emulation

To build aarch64 packages on x86, you need QEMU binfmt support. The exact
module is at `modules/common/binfmt.nix`:

```nix
# modules/common/binfmt.nix
{ ... }: {
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
}
```

It's imported by `modules/common/default.nix`, which means `desktop` and
`laptop` both get it automatically.

Rebuild your build machine:

```bash
sudo nixos-rebuild switch --flake .#laptop
# Reboot to ensure the kernel modules are loaded.
```

Verify binfmt is active:

```bash
cat /proc/sys/fs/binfmt_misc/qemu-aarch64
# Enabled output
```

## 4. Add the host to the flake (already done)

This repo includes the `raspberry-pi` host. The structure is:

```
hosts/rpi/
├── default.nix            # Host config: hostname rpi, extlinux bootloader, nic user with SSH key
└── hardware-configuration.nix   # Generated on the Pi

modules/server/openssh.nix  # SSH daemon config + firewall
modules/common/binfmt.nix   # Exact line:  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
```

## 5. Build the Pi closure on your build machine

```bash
nix build .#nixosConfigurations.raspberry-pi.config.system.build.toplevel \
  --print-out-paths
```

This outputs a store path like `/nix/store/...-nixos-system-rpi-26.05....`.

## 6. Copy the closure to the Pi

```bash
nix copy <store-path> --to ssh://root@<pi-ip>
```

Note: you may need `NIX_SSHOPTS="-t"` if it hangs on password prompts.

## 7. Activate on the Pi

SSH into the Pi and activate directly (skipping `nixos-install` which tries to
unmount the live `/nix/store`):

```bash
ssh root@<pi-ip>
nix-env --profile /nix/var/nix/profiles/system --set <store-path>
<store-path>/bin/switch-to-configuration switch
reboot
```

After reboot the Pi runs the new configuration with the `nic` user and SSH key.

## 8. Subsequent updates

For future rebuilds you can use `nixos-rebuild` remotely from your build
machine:

```bash
NIX_SSHOPTS="-t" nixos-rebuild switch \
  --flake .#raspberry-pi \
  --target-host root@<pi-ip>
```

## Troubleshooting

| Problem | Fix |
|---|---|
| `nix build` fails with aarch64 errors | Ensure `boot.binfmt.emulatedSystems` is set AND the build machine has been rebooted after enabling it |
| `nix copy` hangs | Add `NIX_SSHOPTS="-t"` or use key-based auth for root |
| `nixos-install` tries to umount `/nix/store` | Use `switch-to-configuration` directly instead (step 7) |
| Pi doesn't boot after activation | Select an older generation in the U-Boot boot menu to recover |
