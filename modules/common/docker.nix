{pkgs, ...}: {
  virtualisation.docker = {
    enable = true;
    storageDriver = "overlay2";
    daemon.settings."live-restore" = true;
    autoPrune = {
      enable = true;
      dates = "weekly";
      flags = ["--all"];
    };
  };
}
