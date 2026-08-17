{pkgs, ...}: let
  gcStarted = pkgs.writeShellScript "nix-gc-started" ''
    /run/current-system/sw/bin/post-homepage-message-board "Nix garbage collection started" info
  '';
  gcDone = pkgs.writeShellScript "nix-gc-done" ''
    /run/current-system/sw/bin/post-homepage-message-board "Nix garbage collection completed" success
  '';
  gcFailed = pkgs.writeShellScript "nix-gc-failed" ''
    /run/current-system/sw/bin/post-homepage-message-board "Nix garbage collection failed" error
  '';
in {
  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 5d";
  };

  systemd.services.nix-gc = {
    onFailure = ["nix-gc-failure.service"];
    wants = ["network-online.target"];
    after = ["network-online.target"];
    serviceConfig = {
      ExecStartPre = [gcStarted];
      ExecStartPost = [gcDone];
    };
  };

  systemd.services.nix-gc-failure = {
    description = "Post nix GC failure to message board";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = gcFailed;
    };
  };
}
