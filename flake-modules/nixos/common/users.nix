{...}: {
  flake.modules.nixos.common-users = {pkgs, ...}: {
    programs.zsh.enable = true;

    security.sudo.wheelNeedsPassword = false;

    users.users.root.shell = pkgs.zsh;

    users.users.nic = {
      description = "Christoph Niederer";
      isNormalUser = true;
      extraGroups = ["networkmanager" "wheel" "docker" "video" "greeter"];
      shell = pkgs.zsh;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPrMVVkKpJ532z3GkVnxeQE6SDZXoih0wYCmnaYnaR+f christoph.niederer99@gmail.com"
      ];
    };
  };
}
