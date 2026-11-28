{ config, inputs, ... }:
let
  deployPkgsFor = system:
    import inputs.nixpkgs {
      inherit system;
      overlays = [
        inputs.deploy-rs.overlays.default
        (final: prev: {
          deploy-rs = {
            inherit (inputs.nixpkgs.legacyPackages.${system}) deploy-rs;
            lib = prev.deploy-rs.lib;
          };
        })
      ];
    };

  activateNode = nixosConfig:
    (deployPkgsFor nixosConfig.pkgs.stdenv.hostPlatform.system).deploy-rs.lib.activate.nixos nixosConfig;

  nodes = config.flake.nixosConfigurations;
in
{
  flake.deploy = {
    sshOpts = [
      "-o"
      "StrictHostKeyChecking=no"
      "-o"
      "UserKnownHostsFile=/dev/null"
      "-o"
      "GlobalKnownHostsFile=/dev/null"
      "-o"
      "LogLevel=ERROR"
      "-o"
      "BatchMode=yes"
    ];

    nodes = {
      dobby = {
        hostname = "dobby";
        groups = [ "servers" ];
        profiles.system = {
          user = "root";
          sshUser = "nic";
          path = activateNode nodes.dobby;
        };
      };

      raspberry-pi = {
        hostname = "rpi";
        groups = [ "servers" ];
        profiles.system = {
          user = "root";
          sshUser = "nic";
          path = activateNode nodes.raspberry-pi;
        };
      };

      desktop = {
        hostname = "desktop";
        groups = [ "desktops" ];
        profiles.system = {
          user = "root";
          sshUser = "nic";
          path = activateNode nodes.desktop;
        };
      };

      laptop = {
        hostname = "laptop";
        groups = [ "desktops" ];
        profiles.system = {
          user = "root";
          sshUser = "nic";
          path = activateNode nodes.laptop;
        };
      };
    };
  };
}
