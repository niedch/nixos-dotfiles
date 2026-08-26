{pkgs, ...}: let
  localsend-wrapped = pkgs.symlinkJoin {
    name = "localsend";
    paths = [pkgs.localsend];
    nativeBuildInputs = [pkgs.makeBinaryWrapper];
    postBuild = ''
      for bin in localsend localsend_app; do
        if [ -e "$out/bin/$bin" ]; then
          rm "$out/bin/$bin"
          makeBinaryWrapper "${pkgs.localsend}/bin/$bin" "$out/bin/$bin" \
            --set GTK_CSD "0"
        fi
      done
    '';
  };
in {
  home.packages = [
    localsend-wrapped
  ];
}
