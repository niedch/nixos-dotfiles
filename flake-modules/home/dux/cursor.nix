{ ... }: {
  flake.modules.homeManager.home-dux-cursor = { pkgs, ... }: {
    home.pointerCursor = {
      enable = true;
      gtk.enable = true;
      x11.enable = true;
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 12;
    };
  };
}
