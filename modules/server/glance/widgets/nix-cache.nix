{
  type = "custom-api";
  title = "Nix Cache";
  title-url = "http://dobby:5000";
  cache = "1m";
  url = "http://127.0.0.1:9090/api/v1/query?query=sum(harmonia_http_requests_total%7Bpath%3D%27%2F%7Bhash%7D.narinfo%27%2Cstatus%3D%27200%27%7D)%20or%20vector(0)";
  headers = {
    Accept = "application/json";
  };
  subrequests = {
    misses = {
      url = "http://127.0.0.1:9090/api/v1/query?query=sum(harmonia_http_requests_total%7Bpath%3D%27%2F%7Bhash%7D.narinfo%27%2Cstatus%3D%27404%27%7D)%20or%20vector(0)";
      headers = {
        Accept = "application/json";
      };
    };
    downloads = {
      url = "http://127.0.0.1:9090/api/v1/query?query=sum(harmonia_http_requests_total%7Bpath%3D~%27%2Fnar%2F.*%27%2Cstatus%3D%27200%27%7D)%20or%20vector(0)";
      headers = {
        Accept = "application/json";
      };
    };
    nar404 = {
      url = "http://127.0.0.1:9090/api/v1/query?query=sum(harmonia_http_requests_total%7Bpath%3D~%27%2Fnar%2F.*%27%2Cstatus%3D%27404%27%7D)%20or%20vector(0)";
      headers = {
        Accept = "application/json";
      };
    };
  };
  template = builtins.readFile ../templates/nix-cache.html;
}
