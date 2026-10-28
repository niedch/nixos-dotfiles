{
  type = "custom-api";
  title = "Status";
  title-url = "http://dobby:3001/status/default";
  url = "http://127.0.0.1:3001/api/status-page/default";
  subrequests = {
    heartbeats = {
      url = "http://127.0.0.1:3001/api/status-page/heartbeat/default";
    };
  };
  cache = "1m";
  template = builtins.readFile ../templates/kuma.html;
}
