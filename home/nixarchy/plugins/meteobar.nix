{pkgs, ...}: let
  raw = pkgs.fetchgit {
    name = "meteobar";
    url = "https://github.com/mryll/meteobar.git";
    rev = "4793dd2b988254110407eeadac61b974f264a708";
    hash = "sha256-kPX61LXQbWoHNB7ez8Cb7vd+MPZuJh1M8BjlGmhShXA=";
  };

  meteobar = pkgs.rustPlatform.buildRustPackage {
    pname = "meteobar";
    version = "0.5.4";
    src = raw;
    nativeBuildInputs = [pkgs.pkg-config];
    buildInputs = [pkgs.openssl];
    cargoHash = "sha256-8/uuSj/mbnpktiU2K291QEcEF90cOJJ+mYX8Mjt3Rok=";
  };
in {
  # nixarchy's plugin validation rejects any bundled .qml/.js/.sh/.bash file
  # that mentions `pacman` or `yay`. The upstream panel's only install hint is
  # `yay -S meteobar-bin`, so vendor a patched copy that rewords that string
  # (the binary is provided by home.packages below instead).
  programs.nixarchy.plugins.meteobar.src = pkgs.stdenvNoCC.mkDerivation {
    name = "meteobar-plugin";
    src = raw;
    dontUnpack = true;
    dontPatch = true;
    dontConfigure = true;
    dontBuild = true;
    installPhase = ''
      mkdir -p "$out"
      cp -r "$src/." "$out"
      chmod -R u+w "$out"
      substituteInPlace "$out/omarchy/Panel.qml" \
        --replace-fail "yay -S meteobar-bin" "meteobar (NixOS: add to home.packages)"
    '';
  };

  home.packages = [
    meteobar
    # The panel's location-search suggestions shell out to curl.
    pkgs.curl
  ];
}
