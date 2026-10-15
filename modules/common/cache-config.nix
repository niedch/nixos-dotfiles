{
  ...
}:
{
  nix.settings = {
    substituters = [
      "https://cache.nixos.org"
      "https://nixarchy.cachix.org"
      "https://hyprland.cachix.org"
    ];
    trusted-public-keys = [
      "nixarchy.cachix.org-1:05JOuIlsQOWY2/5DQMq7JEA1hwlhgvmMWowMfka8mMM="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIITemDosxrE9/Kb+PfYvE="
    ];
  };
}
