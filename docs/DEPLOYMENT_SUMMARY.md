# Raspberry Pi Deployment Summary

How to flash, configure, and deploy NixOS to a Raspberry Pi from an x86 build machine using QEMU binfmt emulation.

## Initial Setup

One-time steps to get the Pi running with a stock NixOS image and SSH access.

### 1. Flash the SD image

Download the latest aarch64 SD image from Hydra:

```bash
nix-shell -p wget zstd
```

Browse to the [latest successful build](https://hydra.nixos.org/job/nix/maintenance-2.34/dockerImage.aarch64-linux)
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

### 2. First boot — enable SSH

Boot the Pi, get network connectivity, and start a temporary SSH server so you can manage it remotely from your build machine.

Insert the SD card into the Pi and power it on with HDMI + keyboard attached.
You'll be dropped into a root shell.

#### Get networking

**Ethernet** — plug in; DHCP should work automatically.

**WiFi** — find your interface (`ip link`, usually `wlan0`):

```bash
wpa_supplicant -B -i wlan0 -c <(wpa_passphrase 'SSID' 'passphrase')
ip addr add 192.168.1.X/24 dev wlan0
ip route add default via 192.168.1.1
nix-shell -p dhcpcd
dhcpcd wlan0
```

#### Enable SSH temporarily

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

## Build Machine binfmt Config

Required once on the x86 build machine (desktop/laptop) so Nix can build aarch64 packages via QEMU emulation.

On the x86 build machine (desktop/laptop), add to `configuration.nix`:

```nix
boot.binfmt.emulatedSystems = ["aarch64-linux"];
```

Rebuild and reboot the build machine to load the QEMU kernel modules.

## Deploy / Update

The day-to-day command — builds the Pi configuration on the x86 build machine, copies it over SSH, and activates it on the Pi.

```bash
# Build on x86 machine (desktop/laptop with binfmt emulation)
NIX_SSHOPTS="-t" nixos-rebuild switch \
  --flake .#raspberry-pi \
  --target-host root@<pi-ip>
```

That's it — the build happens cross-compiled on the build machine, copied to the Pi, and activated remotely.