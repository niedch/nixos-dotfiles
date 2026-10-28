{
  type = "group";
  widgets = [
    {
      type = "custom-api";
      title = "Sonarr";
      title-url = "http://dobby:8989";
      url = "http://127.0.0.1:8989/api/v3/series?apikey=\${HOMEPAGE_VAR_SONARR_KEY}";
      subrequests = {
        missing = {
          url = "http://127.0.0.1:8989/api/v3/wanted/missing?apikey=\${HOMEPAGE_VAR_SONARR_KEY}";
        };
        queue = {
          url = "http://127.0.0.1:8989/api/v3/queue?apikey=\${HOMEPAGE_VAR_SONARR_KEY}";
        };
      };
      cache = "1m";
      template = builtins.readFile ../templates/media/sonarr.html;
    }
    {
      type = "custom-api";
      title = "Radarr";
      title-url = "http://dobby:7878";
      url = "http://127.0.0.1:7878/api/v3/movie?apikey=\${HOMEPAGE_VAR_RADARR_KEY}";
      subrequests = {
        missing = {
          url = "http://127.0.0.1:7878/api/v3/wanted/missing?apikey=\${HOMEPAGE_VAR_RADARR_KEY}";
        };
        queue = {
          url = "http://127.0.0.1:7878/api/v3/queue?apikey=\${HOMEPAGE_VAR_RADARR_KEY}";
        };
      };
      cache = "1m";
      template = builtins.readFile ../templates/media/radarr.html;
    }
    {
      type = "custom-api";
      title = "Jellyfin";
      title-url = "http://dobby:8096";
      url = "http://127.0.0.1:8096/Sessions?api_key=\${HOMEPAGE_VAR_JELLYFIN_KEY}";
      subrequests = {
        counts = {
          url = "http://127.0.0.1:8096/Items/Counts?api_key=\${HOMEPAGE_VAR_JELLYFIN_KEY}";
        };
      };
      cache = "30s";
      template = builtins.readFile ../templates/media/jellyfin.html;
    }
    {
      type = "custom-api";
      title = "Immich";
      title-url = "http://dobby:2283";
      url = "http://127.0.0.1:2283/api/server/statistics";
      headers = {
        x-api-key = "\${HOMEPAGE_VAR_IMMICH_KEY}";
        Accept = "application/json";
      };
      cache = "5m";
      template = builtins.readFile ../templates/media/immich.html;
    }
  ];
}
