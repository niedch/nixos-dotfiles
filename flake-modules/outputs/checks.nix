{ config, lib, ... }:
{
  perSystem = { pkgs, ... }: {
    checks = lib.mapAttrs' (
      name: cfg:
      lib.nameValuePair name (pkgs.runCommand "eval-check-${name}" { } ''
        echo "${builtins.unsafeDiscardStringContext cfg.config.system.build.toplevel.drvPath}" > $out
      '')
    ) config.flake.nixosConfigurations;
  };
}
