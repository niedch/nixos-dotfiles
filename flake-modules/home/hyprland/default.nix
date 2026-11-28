{...}: {
  flake.modules.homeManager.home-hyprland = {osConfig, ...}: {
    xdg.configFile."hypr/hyprland.lua".source = ./hyprland.lua;
    xdg.configFile."hypr/config".source = ./config;
    xdg.configFile."hypr/xdph.conf".text = ''
      screencopy {
          allow_token_by_default = true
      }
    '';
  };
}
