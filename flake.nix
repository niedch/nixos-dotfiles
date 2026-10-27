{
  description = "Multi-host NixOS dotfiles and configuration";

  nixConfig = {
    extra-substituters = [
      "http://dobby:5000"
    ];
    extra-trusted-public-keys = [
      "dobby:rrZQzoRX5Glj/0fX+bFGJ6YUPoxb3z/hg5K84k2G8yo="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nixflix = {
      url = "github:kiriwalawren/nixflix";
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

    sops-nix = {
      url = "github:Mic92/sops-nix";
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

    nixarchy = {
      url = "github:olafkfreund/nixarchy/release";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.sops-nix.follows = "sops-nix";
      inputs.home-manager.follows = "home-manager";
    };

    nixcraft = {
      url = "github:niedch/nixcraft";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-lazy-apps = {
      url = "github:niedch/nix-lazy-apps";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    sops-nix,
    nixos-hardware,
    mux-session,
    speedtest-tracker,
    comd,
    nixarchy,
    nixflix,
    nixcraft,
    nix-lazy-apps,
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
        ./hosts/desktop
        ./modules/common
        ./modules/common/syncthing.nix
        ./modules/desktop
        ./modules/server/glances.nix
        ./hosts/laptop/nixarchy-apps.nix
        (mkHM (import ./home/desktop.nix))
      ];

      laptop = mkSystem [
        ./hosts/laptop
        ./modules/common
        ./modules/common/syncthing.nix
        ./modules/desktop
        ./modules/server/glances.nix
        nixos-hardware.nixosModules.dell-precision-5530
        ./hosts/laptop/nixarchy-apps.nix
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
        ./modules/common/syncthing.nix
        nixos-hardware.nixosModules.common-pc-ssd
        ./modules/server/openssh.nix
        ./modules/server/immich.nix
        ./modules/server/nix-cache.nix
        ./modules/server/samba.nix
        ./modules/server/github-runner.nix
        ./modules/server/glances.nix
        ./modules/server/gameserver
        speedtest-tracker.nixosModules.default
        nixflix.nixosModules.default
        ./modules/server/homepage
        ./modules/server/nixflix.nix
        (mkHM (import ./home/server.nix))
      ];
    };

    packages.x86_64-linux.mux-session = import ./home/tools/mux-session/package.nix {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      mux-session = mux-session.packages.x86_64-linux.default;
    };

    packages.x86_64-linux.opencode = import ./home/agents/opencode/package.nix {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
    };

    packages.x86_64-linux.nvim = import ./home/nvim/package.nix {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
    };

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
          nh
        ];
      };
  };
}
