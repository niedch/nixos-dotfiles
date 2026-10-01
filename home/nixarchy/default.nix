{
  inputs,
  ...
}:
{
  imports = [
    inputs.nixarchy.homeManagerModules.nixarchy
    ./hypr/default.nix
    ./theme.nix
    ./plugins.nix
  ];

  programs.nixarchy.enable = true;

  programs.nixarchy = {
    neovim = "off";
  };

  programs.nixarchy.defaultPlugins = {
    rebuild = true;
    pkg = false;
    flatsnap = false;
    gitlab = false;
    github = true;
    herdr = false;
    podman = false;
    distrobox = false;
    microvm = false;
    devenv = true;
    plugin-browser = true;
    omatheme = false;
    ai-mirror = false;
    menu = true;
  };

  xdg.configFile."omarchy/nixarchy-menu.json".source = ./nixarchy-menu.json;
}
