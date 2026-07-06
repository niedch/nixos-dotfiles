{pkgs, ...}: {
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true;
      PermitRootLogin = "no";
    };
  };

  networking.firewall = {
    allowedTCPPorts = [22];
  };
}
