{
  config,
  lib,
  pkgs,
  ...
}: let
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
    script = lib.mkForce ''
      set -euo pipefail

      # In systemd services, stderr is connected to a journal socket which cannot be reopened via /dev/stderr.
      # Re-routing stderr through a pipe ensures /dev/stderr can be opened by tee.
      exec 2> >(cat)

      OUTPUT="$(${config.nix.package.out}/bin/nix-collect-garbage ${config.nix.gc.options} | tee /dev/stderr)"

      SUMMARY="$(printf '%s\n' "$OUTPUT" | grep -oE '[0-9]+ store paths deleted, [^[:space:]]+ [a-zA-Z]+ freed' | tail -n 1 || true)"

      if [ -n "$SUMMARY" ]; then
        /run/current-system/sw/bin/post-homepage-message-board "Nix garbage collection completed ($SUMMARY)" success
      else
        /run/current-system/sw/bin/post-homepage-message-board "Nix garbage collection completed" success
      fi
    '';
  };

  systemd.services.nix-gc-failure = {
    description = "Post nix GC failure to message board";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = gcFailed;
    };
  };
}
