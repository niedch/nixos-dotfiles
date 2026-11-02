{
  config,
  pkgs,
  ...
}: {
  services.gitea = {
    enable = true;
    database.type = "mysql";
    settings.server = {
      ROOT_URL = "http://dobby:3000/";
      HTTP_PORT = 3000;
    };
  };

  sops.secrets."gittea/admin_username" = {
    owner = config.services.gitea.user;
    mode = "0400";
  };

  sops.secrets."gittea/admin_password" = {
    owner = config.services.gitea.user;
    mode = "0400";
  };

  systemd.services.gitea-init-admin = {
    description = "Initialize Gitea admin user from SOPS";
    after = [ "gitea.service" ];
    wants = [ "gitea.service" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      User = config.services.gitea.user;
      Group = config.services.gitea.group;
      WorkingDirectory = config.services.gitea.stateDir;
    };

    environment = {
      USER = config.services.gitea.user;
      HOME = config.services.gitea.stateDir;
      GITEA_WORK_DIR = config.services.gitea.stateDir;
      GITEA_CUSTOM = config.services.gitea.customDir;
    };

    path = [ config.services.gitea.package pkgs.curl ];

    script = ''
      ADMIN_USER="$(cat ${config.sops.secrets."gittea/admin_username".path})"
      ADMIN_EMAIL="admin@localhost"
      ADMIN_PASS="$(cat ${config.sops.secrets."gittea/admin_password".path})"
      PORT="${toString config.services.gitea.settings.server.HTTP_PORT}"

      # Wait up to 60s for Gitea service to be responsive
      for i in $(seq 1 30); do
        if curl -sf "http://127.0.0.1:$PORT/api/v1/version" >/dev/null 2>&1; then
          break
        fi
        sleep 2
      done

      # Only create if user doesn't already exist
      if ! gitea admin user list --admin 2>/dev/null | grep -qw "$ADMIN_USER"; then
        echo "Creating Gitea admin user $ADMIN_USER..."
        gitea admin user create \
          --admin \
          --username "$ADMIN_USER" \
          --password "$ADMIN_PASS" \
          --email "$ADMIN_EMAIL" \
          --must-change-password=false
      else
        echo "Gitea admin user $ADMIN_USER already exists."
      fi
    '';
  };

  networking.firewall.allowedTCPPorts = [ config.services.gitea.settings.server.HTTP_PORT ];
}
