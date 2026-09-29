{
  config,
  lib,
  ...
}: {
  nix.settings = lib.mkIf (config.networking.hostName != "dobby") {
    substituters = ["http://dobby:5000" "https://cache.nixos.org"];
    trusted-public-keys = ["dobby:rrZQzoRX5Glj/0fX+bFGJ6YUPoxb3z/hg5K84k2G8yo="];
  };
}
