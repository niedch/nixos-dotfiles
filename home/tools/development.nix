{ pkgs, ... }: {
  home.packages =
    with pkgs;
    [
      unzip
    ]
    ++ [
      # AWT dependency for the eddi project
      libX11
      libxext
      libxrender
      libxi
      libxtst
    ]
    ++ [
      # Programming languages
      nodejs
      python3
      gnumake
    ];
}
