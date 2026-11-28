{...}: {
  flake.modules.homeManager.home-tools-development = {pkgs, ...}: {
    home.packages =
      with pkgs;
      [
        intellij-idea
      ]
      ++ [
        unzip
      ]
      ++ [
        libX11
        libxext
        libxrender
        libxi
        libxtst
      ]
      ++ [
        nodejs
        python3
        gnumake
      ];
  };
}
