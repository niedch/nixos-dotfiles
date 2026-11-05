{pkgs, ...}: {
  xdg.configFile."hypr/hyprland.lua" = {
    source = ./hyprland.lua;
  };

  xdg.configFile."hypr/bindings.lua" = {
    source = ./bindings.lua;
  };

  xdg.configFile."hypr/looknfeel.lua" = {
    source = ./looknfeel.lua;
  };

  xdg.configFile."hypr/monitors.lua" = {
    source = ./monitors.lua;
  };

  xdg.configFile."hypr/input.lua" = {
    source = ./input.lua;
  };

  xdg.configFile."hypr/monitor-workspaces.lua" = {
    source = ./monitor-workspaces.lua;
  };

  xdg.configFile."default/hypr/monitor-workspaces.lua" = {
    source = ./monitor-workspaces.lua;
  };
}
