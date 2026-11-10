{lib}: let
  rawTemplate = builtins.readFile ../templates/glances.html;
in {
  mkGlancesWidget = {
    name,
    host,
    detailed ? false,
  }: {
    type = "custom-api";
    title = name;
    title-url = "http://${host}:61208";
    cache = "15s";
    url = "http://${host}:61208/api/4/quicklook";
    subrequests =
      {
        fs.url = "http://${host}:61208/api/4/fs";
        sensors.url = "http://${host}:61208/api/4/sensors";
      }
      // lib.optionalAttrs detailed {
        network.url = "http://${host}:61208/api/4/network";
        uptime.url = "http://${host}:61208/api/4/uptime";
        system.url = "http://${host}:61208/api/4/system";
      };
    options.detailed = detailed;
    template = builtins.replaceStrings ["__SERVER_NAME__"] [name] rawTemplate;
  };
}
