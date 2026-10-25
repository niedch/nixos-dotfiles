{
  inputs,
  pkgs,
  ...
}: let
  craftPkgs = inputs.nixcraft.packages.${pkgs.stdenv.hostPlatform.system};
in {
  home.packages = with craftPkgs; [
    # Desktop GUI Applications
    photocraft
    vectorcraft
    deckcraft
    gridcraft
    wordcraft
    # cadcraft
    # lightcraft
    # soundcraft
    # designcraft
    filmcraft
    # effectcraft
    pdfcraft
    figcraft
    # craft-launcher

    # Headless CLI & MCP Automation Tools
    photocraft-cli
    vectorcraft-cli
    deckcraft-cli
    gridcraft-cli
    wordcraft-cli
    # cadcraft-cli
    # lightcraft-cli
    # soundcraft-cli
    # designcraft-cli
    filmcraft-cli
    # effectcraft-cli
    pdfcraft-cli
    figcraft-cli
  ];
}
