{
  config,
  pkgs,
  inputs,
  ...
}: {
  programs.zsh.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.nic = {
    description = "Christoph Niederer";
    isNormalUser = true;
    extraGroups = ["networkmanager" "wheel" "docker" "video"];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPrMVVkKpJ532z3GkVnxeQE6SDZXoih0wYCmnaYnaR+f christoph.niederer99@gmail.com"
    ];
  };
}
