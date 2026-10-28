{
  config,
  pkgs,
  ...
}: let
  inherit (import ./widgets/glances.nix) mkGlancesWidget;
  inherit (import ./widgets/search.nix) searchWidget clockWidget;
  bookmarksWidget = import ./widgets/bookmarks.nix;
  messageBoardWidget = import ./widgets/message-board.nix;
  speedtestWidget = import ./widgets/speedtest.nix;
  kumaWidget = import ./widgets/kuma.nix;
  nixCacheWidget = import ./widgets/nix-cache.nix;
  mediaWidget = import ./widgets/media.nix;
in {
  imports = [
    ./prometheus.nix
    ./kuma.nix
    ./speedtest-tracker.nix
    ./message-board.nix
  ];

  sops.secrets.HOMEPAGE_ENV = {
    restartUnits = ["glance.service"];
  };

  services.glance = {
    enable = true;
    openFirewall = true;
    environmentFile = config.sops.secrets.HOMEPAGE_ENV.path;

    settings = {
      server = {
        host = "0.0.0.0";
        port = 8082;
      };

      branding = {
        app-name = "Dobby Dashboard";
        hide-footer = true;
      };

      theme = {
        background-color = "240 10% 4%";
        primary-color = "217 91% 60%";
        contrast-multiplier = 1.1;
      };

      pages = [
        {
          name = "Home";
          columns = [
            {
              size = "small";
              widgets = [
                searchWidget
                clockWidget
                bookmarksWidget
              ];
            }
            {
              size = "full";
              widgets = [
                messageBoardWidget
                speedtestWidget
                kumaWidget
              ];
            }
            {
              size = "small";
              widgets = [
                {
                  type = "group";
                  widgets = [
                    {
                      type = "server-stats";
                      title = "Dobby";
                      title-url = "http://dobby:61208";
                      servers = [
                        {
                          type = "local";
                          name = "Dobby";
                          hide-mountpoints-by-default = true;
                          mountpoints = {
                            "/".hide = false;
                            "/mnt/hdd".hide = false;
                          };
                        }
                      ];
                    }
                    (mkGlancesWidget {
                      name = "Raspberry Pi";
                      host = "rpi";
                    })
                    (mkGlancesWidget {
                      name = "Desktop";
                      host = "desktop";
                    })
                    (mkGlancesWidget {
                      name = "Laptop";
                      host = "laptop";
                    })
                  ];
                }
                nixCacheWidget
                mediaWidget
              ];
            }
          ];
        }
        {
          name = "Glances";
          slug = "glances";
          columns = [
            {
              size = "full";
              widgets = [
                (mkGlancesWidget {
                  name = "Dobby";
                  host = "localhost";
                })
                (mkGlancesWidget {
                  name = "Raspberry Pi";
                  host = "rpi";
                })
              ];
            }
            {
              size = "full";
              widgets = [
                (mkGlancesWidget {
                  name = "Desktop";
                  host = "desktop";
                })
                (mkGlancesWidget {
                  name = "Laptop";
                  host = "laptop";
                })
              ];
            }
          ];
        }
      ];
    };
  };
}
