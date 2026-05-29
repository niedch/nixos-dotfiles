{ config, pkgs, inputs, ... }:

{
  programs.zsh.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.nic = {
    description = "Christoph Niederer";
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    shell = pkgs.zsh;
  };
}
