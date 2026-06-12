{ pkgs, ... }:

let
  fetchFavicon = { name, domain, sha256 }:
    let
      sanitized = builtins.replaceStrings [ " " ] [ "-" ] name;
      rawIcon = pkgs.fetchurl {
        url = "https://www.google.com/s2/favicons?domain=${domain}&sz=128";
        name = "${sanitized}-favicon";
        inherit sha256;
      };
    in
    pkgs.runCommand "${sanitized}-favicon.png" {
      nativeBuildInputs = [ pkgs.imagemagick ];
    } ''
      convert ${rawIcon} -resize 256x256 PNG32:$out
    '';

  mkWebApp = { name, domain, url, sha256 }:
    let
      iconPath = fetchFavicon { inherit name domain sha256; };
    in
    {
      inherit name;
      exec = "${pkgs.brave}/bin/brave --start-maximized --app=${url}";
      icon = "${iconPath}";
      terminal = false;
      type = "Application";
      categories = [ "Network" "WebBrowser" ];
    };

  webApps = [
    { name = "Github"; domain = "www.github.com"; url = "https://www.github.com"; sha256 = "sha256-GoH7+/Co7+CoqaFvCVHmedu9oTH+AUoVAXYFYZmWjgY="; }
    { name = "Slack"; domain = "app.slack.com"; url = "https://app.slack.com/client/T2M6RN37H/C2M6Y5066"; sha256 = "sha256-3vONfw6TIFUEiBaCgZTV6voOvziOTzYs/wnJ1+6cmos="; }
    { name = "Gmail"; domain = "mail.google.com"; url = "https://mail.google.com/mail/u/0"; sha256 = "sha256-Y+/P6e7aTMWJZcdYekhYhmEsv4eOzY/D5N1ZTbMaZ/0="; }
    { name = "Google Drive"; domain = "drive.google.com"; url = "https://drive.google.com/drive/home"; sha256 = "sha256-fuA69CVNn4VrCPc+NPizUmurse15VLVVexFnwyOKkZw="; }
  ];
in
{
  xdg.desktopEntries = builtins.listToAttrs (map (app: {
    name = app.name;
    value = mkWebApp app;
  }) webApps);

  programs.brave = {
    enable = true;

    commandLineArgs = [
      "--enable-features=BraveVerticalTab"
    ];

    extensions = [
      { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; }
    ];
  };
}
