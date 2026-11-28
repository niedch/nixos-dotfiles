{
  searchWidget = {
    type = "search";
    search-engine = "duckduckgo";
    bangs = [
      {
        title = "YouTube";
        shortcut = "!yt";
        url = "https://www.youtube.com/results?search_query={QUERY}";
      }
      {
        title = "GitHub";
        shortcut = "!gh";
        url = "https://github.com/search?q={QUERY}";
      }
      {
        title = "Nix Packages";
        shortcut = "!np";
        url = "https://search.nixos.org/packages?query={QUERY}";
      }
      {
        title = "NixOS Options";
        shortcut = "!no";
        url = "https://search.nixos.org/options?query={QUERY}";
      }
    ];
  };

  clockWidget = {
    type = "clock";
    hour-format = "24h";
    timezones = [
      {
        timezone = "Europe/Vienna";
      }
    ];
  };
}
