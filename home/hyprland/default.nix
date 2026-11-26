{ pkgs, ... }:
{

  home.packages = with pkgs; [
    hyprland-preview-share-picker
  ];

  xdg.configFile."hypr/hyprland.lua".source = ./hyprland.lua;
  xdg.configFile."hypr/config".source = ./config;
  xdg.configFile."hypr/xdph.conf".text = ''
    screencopy {
        allow_token_by_default = true
        custom_picker_binary = hyprland-preview-share-picker
    }
  '';
}
