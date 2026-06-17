{pkgs, ...}: let
  fetchFavicon = {
    name,
    url,
    sha256,
    faviconDomain ? null,
  }: let
    sanitized = builtins.replaceStrings [" "] ["-"] name;
    domain =
      if faviconDomain != null
      then faviconDomain
      else builtins.head (builtins.match "https://([^/]+).*" url);
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
    faviconDomain ? null,
  }: let
    iconPath = fetchFavicon {inherit name url sha256 faviconDomain;};
  in {
    inherit name;
    exec = "${pkgs.chromium}/bin/chromium --start-maximized --app=${url}";
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
      name = "Slack";
      url = "https://app.slack.com/client/T2M6RN37H/C2M6Y5066";
      sha256 = "sha256-3vONfw6TIFUEiBaCgZTV6voOvziOTzYs/wnJ1+6cmos=";
    }
    {
      name = "Google Mail";
      url = "https://mail.google.com/mail/u/0";
      sha256 = "sha256-Y+/P6e7aTMWJZcdYekhYhmEsv4eOzY/D5N1ZTbMaZ/0=";
    }
    {
      name = "Google Drive";
      url = "https://drive.google.com/drive/home";
      sha256 = "sha256-fuA69CVNn4VrCPc+NPizUmurse15VLVVexFnwyOKkZw=";
    }
    {
      name = "Amazon Prime";
      url = "https://www.amazon.de/gp/video/storefront";
      sha256 = "sha256-fmf7jmxDAC4Jx9Nj87FYpxbcCfQEPMBYvMAbIGu9CX0=";
    }
    {
      name = "Youtube";
      url = "https://www.youtube.com/ ";
      sha256 = "sha256-y2rbGYQ7ZFvCJxgfUnRvAemo/abBEzjKwjxZd8fSOGw=";
    }
    {
      name = "Twitch";
      url = "https://www.twitch.tv/";
      sha256 = "sha256-PwTSKGIAQhu4rQxJlXeo+0Ei1kWd0Ks/wBTPnC8GiWM=";
    }
    {
      name = "Reddit";
      url = "https://www.reddit.com/";
      sha256 = "sha256-NjwuoqwsnmBuOG6ihwzxzGtB4Ldr8bHXgy7R98fZDdE=";
    }
    {
      name = "HackerNews";
      url = "https://news.ycombinator.com/";
      sha256 = "sha256-Nbd6mmGer2TKpwuzMqRhSU/IdLIAomIm+f1flCuI0K8=";
    }
    {
      name = "Discord";
      url = "https://discord.com/channels/@me";
      sha256 = "sha256-Q51DlMl/2XLwrAR7UDh35Ley44dvw92ePp7MOP0Ojlo=";
    }
    {
      name = "Whatsapp";
      url = "https://web.whatsapp.com/";
      sha256 = "sha256-X7icJI6OfjNFIp3sos3/k8EPlMswZ0veNqsdsbtkPac=";
      faviconDomain = "whatsapp.com";
    }
  ];
in {
  xdg.desktopEntries = builtins.listToAttrs (map (app: {
      name = app.name;
      value = mkWebApp app;
    })
    webApps);

  programs.chromium = {
    enable = true;

    commandLineArgs = [
      "--ignore-gpu-blocklist"
      "--enable-gpu-rasterization"
      "--enable-features=Vulkan,UseSkiaRenderer"
      "--enable-features=VaapiVideoDecoder,VaapiVideoEncoder,UseMultiPlaneFormatForSoftwareOverlayVideo"
      "--disable-gpu-driver-bug-workarounds"
    ];

    extensions = [
      {id = "cjpalhdlnbpafiamejdnhcphjbkeiagm";}
    ];
  };
}
