{...}: {
  flake.modules.nixos.common-glances = {pkgs, ...}: {
    services.glances = {
      enable = true;
      port = 61208;
      openFirewall = true;
      package = pkgs.glances.overridePythonAttrs {
        doCheck = false;
      };
      extraArgs = [
        "--webserver"
      ];
    };
  };
}
