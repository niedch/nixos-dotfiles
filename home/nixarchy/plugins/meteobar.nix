{pkgs, ...}: let
  raw = pkgs.fetchgit {
    name = "meteobar";
    url = "https://github.com/mryll/meteobar.git";
    rev = "0bf888488c98551b64b191b822e381ef96d849ec";
    hash = "sha256-Nr5/BvQOCgjk1LvCnynGR3hOaY3ol5aUsiG1ragR2kg=";
  };

  meteobar = pkgs.rustPlatform.buildRustPackage {
    pname = "meteobar";
    version = "0.5.8";
    src = raw;
    nativeBuildInputs = [pkgs.pkg-config];
    buildInputs = [pkgs.openssl];
    cargoHash = "sha256-NeksKf1l01z1f9hNl+2Ys1lZr/k59ig4T4dtXUulul8=";
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
