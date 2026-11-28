{...}: {
  flake.modules.nixos.common-binfmt = {...}: {
    boot.binfmt.emulatedSystems = ["aarch64-linux"];
  };
}
