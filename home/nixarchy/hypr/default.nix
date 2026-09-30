{ pkgs, ... }: {
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
}
