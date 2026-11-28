{...}: {
  flake.modules.homeManager.home-dux-calendar = {...}: {
    programs.dank-calendar = {
      enable = true;
      systemd = {
        enable = true;
        restartIfChanged = true;
      };
    };
  };
}
