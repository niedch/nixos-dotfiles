{ pkgs, ... }: {
  services.cockpit = {
    enable = true;
    port = 9292;
    openFirewall = true;

    # 1. Allow unencrypted HTTP access
    settings = {
      WebService = {
        AllowUnencrypted = true;
      };
    };

    # 2. Allow your local hostname / IP over plain HTTP
    allowed-origins = [
      "http://localhost:9292"
      "https://localhost:9292"
      "http://dobby:9292"
      "https://dobby:9292"
      "http://192.168.1.50:9292" # Replace with dobby's actual local IP
      "https://192.168.1.50:9292" # Replace with dobby's actual local IP
    ];
  };
}
