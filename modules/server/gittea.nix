{ config, ... }: {
  services.gitea = {
    enable = true;
    database.type = "mysql";
    settings.server = {
      ROOT_URL = "http://dobby:3000/";
      HTTP_PORT = 3000;
    };
  };

  networking.firewall.allowedTCPPorts = [ config.services.gitea.settings.server.HTTP_PORT ];
}
