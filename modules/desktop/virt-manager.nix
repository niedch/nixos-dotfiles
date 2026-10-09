{pkgs, ...}: {
  virtualisation.libvirtd = {
    enable = true;
    # swtpm provides TPM emulation, required for Windows 11 guests.
    qemu.swtpm.enable = true;
  };

  programs.virt-manager.enable = true;

  # dnsmasq provides DNS/DHCP for libvirt's default NAT network (virbr0).
  environment.systemPackages = [pkgs.dnsmasq];

  # Allow user `nic` to manage VMs via libvirt without root.
  users.users.nic.extraGroups = ["libvirtd"];
}
