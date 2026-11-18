{ osConfig, ... }:
{
  xdg.configFile."hypr/hyprland.lua".source = ./hyprland.lua;
  xdg.configFile."hypr/config".source = ./config;
}
