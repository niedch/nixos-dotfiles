{
  pkgs,
  lib,
  ...
}: let
  wallpapers = {
    "malboro-car.jpg" = {
      url = "https://w.wallhaven.cc/full/d8/wallhaven-d8vvlo.png";
      hash = "sha256-rdf7N8ux2R2cQaxDfhyXOGCstDDFy3wzBfWDci99M4k=";
    };
    "banff.jpg" = {
      url = "https://w.wallhaven.cc/full/e8/wallhaven-e8v1x8.jpg";
      hash = "sha256-GIUE/tvBE/Ei43T6kOPYFBsWy74sqs2TBAZs9NJNveM=";
    };
    "icefields.jpg" = {
      url = "https://w.wallhaven.cc/full/po/wallhaven-pomx99.jpg";
      hash = "sha256-FFdtO9YODPpVoOh5tzlurRLmCDiNoNHyBe6apDOGgiA=";
    };
    "mist_drawing.jpg" = {
      url = "https://w.wallhaven.cc/full/qr/wallhaven-qrp5xd.jpg";
      hash = "sha256-mK1i+6Pl/nNsNLJ0Q3ZiY9y4+y1dILJ5Zf/vFHAZgRw=";
    };
  };
in {
  xdg.configFile = lib.mapAttrs' (
    filename: img:
      lib.nameValuePair "dms/wallpapers/${filename}" {
        source = pkgs.fetchurl {inherit (img) url hash;};
      }
  ) wallpapers;
}

