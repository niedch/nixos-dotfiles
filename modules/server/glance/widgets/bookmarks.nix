{
  type = "bookmarks";
  groups = [
    {
      title = "Infrastructure";
      links = [
        {
          title = "Homebridge";
          url = "http://rpi:8581";
        }
        {
          title = "Samba Share";
          url = "//dobby/share";
        }
        {
          title = "Syncthing";
          url = "http://dobby:8384";
        }
        {
          title = "GitHub Runner";
          url = "https://github.com/niedch/nixos-dotfiles/actions";
        }
        {
          title = "Valheim";
          url = "steam://connect/dobby:2457";
        }
      ];
    }
    {
      title = "Media & Downloads";
      links = [
        {
          title = "Immich";
          url = "http://dobby:2283";
          description = "Photo & Video Management";
          icon = "si:immich";
        }
        {
          title = "Jellyfin";
          url = "http://dobby:8096";
          description = "Media Streaming";
          icon = "si:jellyfin";
        }
        {
          title = "Sonarr";
          url = "http://dobby:8989";
          description = "TV Series Management";
          icon = "si:sonarr";
        }
        {
          title = "Radarr";
          url = "http://dobby:7878";
          description = "Movie Management";
          icon = "si:radarr";
        }
        {
          title = "Prowlarr";
          url = "http://dobby:9696";
          description = "Indexer Management";
          icon = "si:prowlarr";
        }
        {
          title = "qBittorrent";
          url = "http://dobby:8282";
          description = "Torrent Client";
          icon = "si:qbittorrent";
        }
        {
          title = "Seerr";
          url = "http://dobby:5055";
          description = "Media Requests";
          icon = "sh:seerr";
        }
      ];
    }
  ];
}
