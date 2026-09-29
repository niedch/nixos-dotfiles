{inputs, ...}: {
  imports = [
    inputs.nixarchy.homeManagerModules.nixarchy
  ];

  programs.nixarchy.enable = true;
  programs.nixarchy.neovim = "off";

  programs.nixarchy.defaultPlugins = {
    rebuild = true;
    pkg = true;
    flatsnap = false;
    gitlab = false;
    github = false;
    herdr = false;
    podman = false;
    distrobox = false;
    microvm = true;
    devenv = true;
    plugin-browser = true;
    omatheme = true;
    ai-mirror = false;
    menu = true;
  };
}
