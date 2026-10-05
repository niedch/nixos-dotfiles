{ pkgs, ... }:
let
  raw = pkgs.fetchgit {
    name = "omarchy-lock-explorer";
    url = "https://github.com/SirJul1337/omarchy-lock-explorer.git";
    rev = "b6ed7bded638483bce77604d239e365e16452517";
    hash = "sha256-zilpNyTorPXMByKSNcKkTSXf7PF8KJlTlaZdblxBL5s=";
  };
in
{
  # The plugin's source mentions `pacman` in a few prose strings and optional
  # `extras/` scripts, which nixarchy's plugin-lock check refuses on NixOS.
  # Those are all optional (qt6-multimedia = video designs, qt6-imageformats =
  # WebP wallpaper, pam-u2f/libfido2 = FIDO2 unlock), so vendor a patched copy
  # that rewords the messages and neutralises the pacman probes.
  programs.nixarchy.plugins.lock.src = pkgs.stdenvNoCC.mkDerivation {
    name = "omarchy-lock-explorer";
    src = raw;
    dontUnpack = true;
    dontPatch = true;
    dontConfigure = true;
    dontBuild = true;
    installPhase = ''
      mkdir -p "$out"
      cp -r "$src/." "$out"
      chmod -R u+w "$out"
      substituteInPlace "$out/Service.qml" \
        --replace-fail "sudo pacman -S qt6-multimedia" "qt6-multimedia (Install menu)"
      substituteInPlace "$out/Explorer.qml" \
        --replace-fail "sudo pacman -S qt6-imageformats" "qt6-imageformats (Install menu)"
      substituteInPlace "$out/extras/doctor.sh" \
        --replace-fail "pacman -Q qt6-multimedia" "false" \
        --replace-fail "pacman -Q qt6-imageformats" "false"
      substituteInPlace "$out/extras/setup-fido2.sh" \
        --replace-fail "sudo pacman -S --needed pam-u2f libfido2" "pam_u2f and libfido2 (NixOS config)"
    '';
  };
}
