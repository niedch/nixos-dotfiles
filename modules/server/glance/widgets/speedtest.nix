{
  type = "custom-api";
  title = "Internet Speed";
  title-url = "http://dobby:8080/dashboard/";
  cache = "30m";
  url = "http://127.0.0.1:8080/api/v1/results/latest";
  headers = {
    Accept = "application/json";
  };
  subrequests = {
    stats = {
      url = "http://127.0.0.1:8080/api/v1/stats";
      headers = {
        Accept = "application/json";
      };
    };
  };
  template = builtins.readFile ../templates/speedtest.html;
}
