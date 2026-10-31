{inputs, ...}: {
  imports = [
    inputs.nixarchy.homeManagerModules.nixarchy
    ./theme.nix
    ./hypr
    ./plugins
  ];

  programs.nixarchy = {
    enable = true;
    neovim = "off";
  };

  programs.nixarchy.defaultPlugins = {
    rebuild = true;
    pkg = false;
    flatsnap = false;
    gitlab = false;
    github = true;
    herdr = true;
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
  xdg.configFile."omarchy/shell.toml".source = ./omarchy-shell.toml;
}
