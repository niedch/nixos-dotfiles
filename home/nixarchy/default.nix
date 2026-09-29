{inputs, ...}: {
  imports = [
    inputs.nixarchy.homeManagerModules.nixarchy
  ];

  programs.nixarchy.enable = true;
  programs.nixarchy.neovim = "off";

  programs.nixarchy.defaultPlugins = {
    rebuild = false;
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
    menu = false;
  };
}
