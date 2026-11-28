{...}: {
  flake.modules.homeManager.home-tools-btop = {pkgs, ...}: {
    programs.btop = {
      enable = true;
      package = pkgs.btop.override {cudaSupport = true;};
    };
  };
}
