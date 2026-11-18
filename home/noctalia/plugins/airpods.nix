{
  pkgs,
  lib,
  ...
}: let
  airpods-src = pkgs.fetchFromGitHub {
    owner = "harveywuk";
    repo = "airpods";
    rev = "f02b3a95907762cf216a6c489b085862e95f8292";
    hash = "sha256-zMxPT9SF+wIlFGGuhj70yqABIkefL19FNvEadLy5r4A=";
  };

  omapods-src = pkgs.fetchgit {
    name = "omarchy-pods";
    url = "https://github.com/thisisgm/omarchy-pods.git";
    rev = "fff7fec600a5b9a61cdb40e93eccbcceb4b8f824";
    hash = "sha256-CMPeGfsLQQSYL1zsBAXChUHkSVTAoSvRlmHhpQoaK0A=";
  };

  librepods = pkgs.stdenv.mkDerivation {
    pname = "librepods";
    version = "1.3.6";
    src = omapods-src;
    sourceRoot = "omarchy-pods/daemon";
    nativeBuildInputs = [
      pkgs.cmake
      pkgs.ninja
      pkgs.pkg-config
      pkgs.qt6.wrapQtAppsHook
    ];
    buildInputs = [
      pkgs.qt6.qtbase
      pkgs.qt6.qtdeclarative
      pkgs.qt6.qtconnectivity
      pkgs.qt6.qttools
      pkgs.openssl
      pkgs.libpulseaudio
    ];
    cmakeFlags = ["-DBUILD_TESTING=OFF"];
    meta = with lib; {
      description = "librepods AirPods daemon (fork bundled with omarchy-pods)";
      license = licenses.gpl3Only;
      platforms = platforms.linux;
      mainProgram = "librepods";
    };
  };
in {
  # Noctalia scans ~/.local/share/noctalia/plugins/<plugin>/ for local plugins
  xdg.dataFile."noctalia/plugins/airpods".source = airpods-src;

  # Installs librepods and librepods-ctl into PATH
  home.packages = [librepods];

  systemd.user.services.librepods = {
    Unit = {
      Description = "librepods AirPods daemon";
      After = ["graphical-session.target"];
      PartOf = ["graphical-session.target"];
    };
    Service = {
      Type = "simple";
      Environment = ["QT_LOGGING_RULES=openpods.debug=false"];
      ExecStart = "${librepods}/bin/librepods --headless";
      Restart = "on-failure";
      RestartSec = 5;
      UMask = "0077";
      StateDirectory = "librepods";
      StateDirectoryMode = "0700";
      ConfigurationDirectory = "AirPodsTrayApp";
      ConfigurationDirectoryMode = "0700";
      ProtectSystem = "strict";
      ProtectHome = "read-only";
      ReadWritePaths = ["%t"];
      PrivateTmp = true;
      NoNewPrivileges = true;
      CapabilityBoundingSet = "";
      RestrictSUIDSGID = true;
      RestrictNamespaces = true;
      LockPersonality = true;
      SystemCallArchitectures = "native";
      ProtectKernelTunables = true;
      ProtectKernelModules = true;
      ProtectKernelLogs = true;
      ProtectControlGroups = true;
      ProtectClock = true;
      ProtectHostname = true;
      RestrictAddressFamilies = "AF_UNIX AF_BLUETOOTH AF_NETLINK";
    };
    Install = {
      WantedBy = ["graphical-session.target"];
    };
  };
}
