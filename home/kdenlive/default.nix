{
  pkgs,
  ...
}: let
  kdenlive-wrapped = pkgs.symlinkJoin {
    name = "kdenlive-wrapped";
    paths = [pkgs.kdePackages.kdenlive];
    nativeBuildInputs = [pkgs.makeWrapper];
    postBuild = ''
      for bin in kdenlive kdenlive_render; do
        rm "$out/bin/$bin"
        makeWrapper "${pkgs.kdePackages.kdenlive}/bin/$bin" "$out/bin/$bin" \
          --set LADSPA_PATH "${pkgs.rnnoise-plugin.ladspa}/lib/ladspa"
      done
    '';
  };
in {
  home.packages = [kdenlive-wrapped pkgs.rnnoise-plugin];
}
