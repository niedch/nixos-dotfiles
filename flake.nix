{
  description = "Multi host Nixos + hyperland config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    microvm = {
      url = "github:astro/microvm.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    wlctl = {
      url = "github:aashish-thapa/wlctl";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-omarchy-theme = {
      url = "github:niedch/nix-omarchy-theme";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-omarchy-quickshell = {
      url = "path:/home/nic/Projects/nix-omarchy-quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mux-session = {
      url = "github:niedch/mux-session";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    speedtest-tracker = {
      url = "github:niedch/speedtest-tracker";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    comd = {
      url = "github:niedch/comd";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    opencode-waybar-status = {
      url = "github:niedch/opencode-waybar-status";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    microvm,
    home-manager,
    nix-omarchy-theme,
    nix-omarchy-quickshell,
    sops-nix,
    wlctl,
    nixos-hardware,
    mux-session,
    speedtest-tracker,
    comd,
    opencode-waybar-status,
    ...
  } @ inputs: let
    mkSystem = extraModules:
      nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules =
          extraModules
          ++ [
            sops-nix.nixosModules.sops
            home-manager.nixosModules.home-manager
          ];
      };

    mkHM = userConfig: {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.backupFileExtension = "backup";
      home-manager.extraSpecialArgs = {inherit inputs;};
      home-manager.sharedModules = [sops-nix.homeManagerModules.sops];
      home-manager.users.nic = userConfig;
    };
  in {
    nixosConfigurations = {
      desktop = mkSystem [
        ./hosts/virtual-machine
        ./modules/common
        ./modules/desktop
        inputs.nix-omarchy-quickshell.nixosModules.default
        (mkHM (import ./home/desktop.nix))
      ];

      laptop = mkSystem [
        ./hosts/laptop
        ./modules/common
        ./modules/desktop
        inputs.nix-omarchy-quickshell.nixosModules.default
        ./modules/server/glances.nix
        nixos-hardware.nixosModules.dell-precision-5530
        (mkHM (import ./home/desktop.nix))
      ];

      raspberry-pi = mkSystem [
        # nixos-hardware.nixosModules.raspberry-pi-3
        ./hosts/rpi
        ./modules/common/sops.nix
        ./modules/common/ssh.nix
        ./modules/common/users.nix
        ./modules/common/cache-config.nix
        ./modules/common/nix-gc.nix
        ./modules/common/message-board-client.nix
        ./modules/server
        ./modules/server/homebridge
        (mkHM (import ./home/server.nix))
      ];

      dobby = mkSystem [
        ./hosts/dobby
        ./modules/common
        nixos-hardware.nixosModules.common-pc-ssd
        ./modules/server/openssh.nix
        ./modules/server/immich.nix
        ./modules/server/nix-cache.nix
        ./modules/server/nix-gc-cache.nix
        ./modules/server/samba.nix
        ./modules/server/github-runner.nix
        ./modules/server/glances.nix
        speedtest-tracker.nixosModules.default
        ./modules/server/homepage
        (mkHM (import ./home/server.nix))
      ];

      microvm = mkSystem [
        ./hosts/microvm
        ./modules/common
        ./modules/desktop
        inputs.nix-omarchy-quickshell.nixosModules.default
        (mkHM (import ./home/microvm.nix))
      ];
    };

    packages.x86_64-linux.mux-session = import ./home/tools/mux-session/package.nix {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      mux-session = mux-session.packages.x86_64-linux.default;
    };

    packages.x86_64-linux.opencode = import ./home/opencode/package.nix {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
    };

    packages.x86_64-linux.nvim = import ./home/nvim/package.nix {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
    };

    packages.x86_64-linux.microvm =
      self.nixosConfigurations.microvm.config.microvm.declaredRunner;

    devShells.x86_64-linux.default = let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in
      pkgs.mkShell {
        shellHook = "mise tasks ls";
        packages = with pkgs; [
          alejandra
          jq
          mise
          watchexec
          sops
        ];
      };
  };
}
