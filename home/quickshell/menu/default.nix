{
  pkgs,
  lib,
  ...
}: let
  scripts = import ./scripts.nix {inherit pkgs;};

  scriptDerivations =
    builtins.map (s: let
      binPath = (lib.optionalString (s.selfPath or false) "$out/bin:") + lib.makeBinPath (s.deps or []);
      envFlags = lib.concatStringsSep " " (
        lib.mapAttrsToList (k: v: ''--set ${k} "${v}"'') (s.envs or {})
      );
    in ''
      cp ${./src}/${s.name}.sh $out/bin/${s.name}
      chmod +x $out/bin/${s.name}
      wrapProgram $out/bin/${s.name} \
        ${envFlags} \
        --prefix PATH : ${binPath}
    '')
    scripts;

  menuScripts =
    pkgs.runCommand "menu-scripts" {
      nativeBuildInputs = [pkgs.makeWrapper];
    } ''
      mkdir -p $out/bin
      ${lib.concatStringsSep "\n" scriptDerivations}
    '';
in {
  home.packages = [
    menuScripts
  ];
}
