{ ... }:
{
  perSystem = { pkgs, ... }: {
    devShells.default = pkgs.mkShell {
      shellHook = "mise tasks ls";
      packages = with pkgs; [
        alejandra
        jq
        mise
        watchexec
        sops
        nh
        pkgs.deploy-rs
      ];
    };
  };
}
