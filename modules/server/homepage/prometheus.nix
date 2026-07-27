{...}: {
  services.prometheus = {
    enable = true;
    port = 9090;
    listenAddress = "127.0.0.1";
    scrapeConfigs = [
      {
        job_name = "harmonia";
        static_configs = [
          {targets = ["127.0.0.1:5000"];}
        ];
      }
    ];
  };
}
