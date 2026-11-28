{...}: {
  flake.modules.nixos.common-cache-config = {...}: {
    nix.settings = {
      substituters = [
        "http://dobby:5000"
        "https://cache.nixos.org"
        "https://hyprland.cachix.org"
        "https://noctalia.cachix.org"
      ];
      trusted-public-keys = [
        "dobby:rrZQzoRX5Glj/0fX+bFGJ6YUPoxb3z/hg5K84k2G8yo="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIITemDosxrE9/Kb+PfYvE="
        "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
      ];
      connect-timeout = 5;
    };
  };
}
