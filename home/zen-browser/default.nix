{ pkgs, inputs, ... }:

{
  home.packages = [
    inputs.zen-browser.packages.${pkgs.system}.default
  ];

  xdg.desktopEntries = {
    youtube = {
      name = "YouTube";
      exec = "${inputs.zen-browser.packages.${pkgs.system}.default}/bin/zen -P Webapp --new-window https://youtube.com";
      terminal = false;
      categories = [ "Network" "WebBrowser" ];
    };

    github = {
      name = "github";
      exec = "${inputs.zen-browser.packages.${pkgs.system}.default}/bin/zen -P Webapp --new-window https://github.com/";
      terminal = false;
      categories = [ "Network" "WebBrowser" ];
    };
  };
}
