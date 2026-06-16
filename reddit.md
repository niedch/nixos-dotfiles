Hi, i just want to share this beauty with you guys, i know its probably not that crazy for some of you wizards but still found it amazing:

{pkgs, ...}: let
  fetchFavicon = {
    name,
    url,
    sha256,
  }: let
    sanitized = builtins.replaceStrings [" "] ["-"] name;
    domain = builtins.head (builtins.match "https://([^/]+).*" url);
    rawIcon = pkgs.fetchurl {
      url = "https://www.google.com/s2/favicons?domain=${domain}&sz=256";
      name = "${sanitized}-favicon.png";
      inherit sha256;
    };
  in
    rawIcon;

  mkWebApp = {
    name,
    url,
    sha256,
  }: let
    iconPath = fetchFavicon {inherit name url sha256;};
  in {
    inherit name;
    exec = "${pkgs.brave}/bin/brave --start-maximized --app=${url}";
    icon = "${iconPath}";
    terminal = false;
    type = "Application";
    categories = ["Network" "WebBrowser"];
  };

  webApps = [
    {
      name = "Github";
      url = "https://www.github.com";
      sha256 = "sha256-GoH7+/Co7+CoqaFvCVHmedu9oTH+AUoVAXYFYZmWjgY=";
    }
    
    {
      name = "Reddit";
      url = "https://www.reddit.com/";
      sha256 = "sha256-NjwuoqwsnmBuOG6ihwzxzGtB4Ldr8bHXgy7R98fZDdE=";
    }
    ...
  ];
in {
  xdg.desktopEntries = builtins.listToAttrs (map (app: {
      name = app.name;
      value = mkWebApp app;
    })
    webApps);

  programs.brave = {
    enable = true;

    commandLineArgs = [
      "--enable-features=BraveVerticalTab"
    ];

    extensions = [
      {id = "cjpalhdlnbpafiamejdnhcphjbkeiagm";}
    ];
  };
}

This will create Desktop Entries for each webpage add the favicon as the Desktop Icon.
