{
  description = "Multi host Nixos + hyperland config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
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

    mux-session = {
      url = "github:niedch/mux-session";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    opencode-waybar-status = {
      url = "github:niedch/opencode-waybar-status";
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

    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nix-omarchy-theme,
    sops-nix,
    wlctl,
    nixos-hardware,
    mux-session,
    opencode-waybar-status,
    speedtest-tracker,
    comd,
    niri,
    noctalia,
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
        {nixosDotfiles.noctalia.enable = true;}
        (mkHM {
          imports = [
            (import ./home/desktop.nix)
            ./home/noctalia/default.nix
            {nixosDotfiles.noctalia.enable = true;}
          ];
        })
      ];

      laptop = mkSystem [
        ./hosts/laptop
        ./modules/common
        ./modules/desktop
        ./modules/server/glances.nix
        nixos-hardware.nixosModules.dell-precision-5530
        {nixosDotfiles.noctalia.enable = true;}
        (mkHM {
          imports = [
            (import ./home/desktop.nix)
            ./home/noctalia/default.nix
            {nixosDotfiles.noctalia.enable = true;}
          ];
        })
      ];

      raspberry-pi = mkSystem [
        # nixos-hardware.nixosModules.raspberry-pi-3
        ./hosts/rpi
        ./modules/common/sops.nix
        ./modules/common/ssh.nix
        ./modules/common/users.nix
        ./modules/common/cache-config.nix
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
        ./modules/server/samba.nix
        ./modules/server/github-runner.nix
        ./modules/server/glances.nix
        speedtest-tracker.nixosModules.default
        ./modules/server/homepage
        (mkHM (import ./home/server.nix))
      ];
    };

    devShells.x86_64-linux.default = let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in
      pkgs.mkShell {
        packages = with pkgs; [alejandra jq mise sops];
        shellHook = "mise tasks ls";
      };
  };
}
