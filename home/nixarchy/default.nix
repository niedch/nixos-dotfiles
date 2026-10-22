{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.nixarchy.homeManagerModules.nixarchy
    ./hypr/default.nix
    ./theme.nix
    ./plugins
  ];

  programs.nixarchy.enable = true;

  programs.nixarchy = {
    package = pkgs.omarchy;
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

  xdg.configFile."omarchy/shell.toml".text = ''
    [bar]
    background-alpha = 0.7
  '';
}
