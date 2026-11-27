{ ... }: {
  programs.dank-calendar = {
    enable = true;
    systemd = {
      enable = true;
      restartIfChanged = true;
    };
  };
}
