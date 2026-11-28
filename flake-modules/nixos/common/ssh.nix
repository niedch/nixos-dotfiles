{...}: {
  flake.modules.nixos.common-ssh = {...}: {
    services.openssh.enable = true;
  };
}
