{ pkgs, ... }: {
  home.packages = with pkgs; [
    spotify
    spicetify-cli
  ];
}
