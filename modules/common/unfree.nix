{...}: {
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # TODO: Remove once glances / python-jose is updated or patched in nixpkgs (CVE-2026-120459)
  nixpkgs.config.permittedInsecurePackages = [
    "python3.14-python-jose-3.5.0"
  ];
}
