{
  self,
  nixpkgs,
  deploy-rs,
  ...
}: let
  deployPkgsFor = system:
    import nixpkgs {
      inherit system;
      overlays = [
        deploy-rs.overlays.default
        (final: prev: {
          deploy-rs = {
            inherit (nixpkgs.legacyPackages.${system}) deploy-rs;
            lib = prev.deploy-rs.lib;
          };
        })
      ];
    };

  activateNode = nixosConfig: (deployPkgsFor nixosConfig.pkgs.system).deploy-rs.lib.activate.nixos nixosConfig;
in {
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
      groups = ["servers"];
      profiles.system = {
        user = "root";
        sshUser = "nic";
        path = activateNode self.nixosConfigurations.dobby;
      };
    };

    raspberry-pi = {
      hostname = "rpi";
      groups = ["servers"];
      profiles.system = {
        user = "root";
        sshUser = "nic";
        path = activateNode self.nixosConfigurations.raspberry-pi;
      };
    };

    desktop = {
      hostname = "desktop";
      groups = ["desktops"];
      profiles.system = {
        user = "root";
        sshUser = "nic";
        path = activateNode self.nixosConfigurations.desktop;
      };
    };

    laptop = {
      hostname = "laptop";
      groups = ["desktops"];
      profiles.system = {
        user = "root";
        sshUser = "nic";
        path = activateNode self.nixosConfigurations.laptop;
      };
    };
  };
}
