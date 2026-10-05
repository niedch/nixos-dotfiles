{ pkgs, lib, ... }: {
  programs.nixarchy.plugins.numr.src = pkgs.fetchgit {
    name = "omarchy-numr";
    url = "https://github.com/niedch/omarchy-numr-plugin.git";
    rev = "f8b0de9d7a376c1e8237bbb9239223aef1685f3e";
    hash = "sha256-gGyYcgpFlJSoaRjvj+wYHIlzVVObM0KZjBrKmkouCKQ=";
  };

  home.packages = with pkgs; [
    numr
  ];
}
