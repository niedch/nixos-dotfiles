{
	description = "Multi host Nixos + hyperland config";

	inputs = {
		nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

		home-manager = {
			url = "github:nix-community/home-manager/release-26.05";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		hyprland.url = "github:hyprwm/Hyprland";

		nix-omarchy-theme = {
			url = "path:/home/nic/Projects/nix-omarchy-theme";
			inputs.nixpkgs.follows = "nixpkgs";

		};

		gazelle-tui.url = "github:Zeus-Deus/gazelle-tui";

		zen-browser.url = "github:youwen5/zen-browser-flake";

		sops-nix = {
			url = "github:Mic92/sops-nix";
			inputs.nixpkgs.follows = "nixpkgs";
		};

    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
      inputs.nixpkgs.follows = "nixpkgs";
    };
	};

	outputs = {self, nixpkgs, home-manager, hyprland, nix-omarchy-theme, zen-browser, sops-nix, nixos-hardware, ...  } @ inputs: {
		nixosConfigurations = {
			desktop = nixpkgs.lib.nixosSystem {
				specialArgs = { inherit inputs; };
				modules = [
					./hosts/virtual-machine
					./modules/common
					./modules/desktop
					sops-nix.nixosModules.sops
					home-manager.nixosModules.home-manager {
						home-manager.useGlobalPkgs = true;
						home-manager.useUserPackages = true;
						home-manager.backupFileExtension = "backup";
						home-manager.extraSpecialArgs = { inherit inputs; };
						home-manager.sharedModules = [ sops-nix.homeManagerModules.sops ];
						home-manager.users.nic = import ./home/desktop.nix;
					}
				];
			};

			laptop = nixpkgs.lib.nixosSystem {
				specialArgs = { inherit inputs; };
				modules = [
					./hosts/laptop
					./modules/common
					./modules/desktop
          nixos-hardware.nixosModules.dell-precision-5530					
          sops-nix.nixosModules.sops
					home-manager.nixosModules.home-manager {
						home-manager.useGlobalPkgs = true;
						home-manager.useUserPackages = true;
						home-manager.backupFileExtension = "backup";
						home-manager.extraSpecialArgs = { inherit inputs; };
						home-manager.sharedModules = [ sops-nix.homeManagerModules.sops ];
						home-manager.users.nic = import ./home/desktop.nix;
					}
				];
			};

			dobby = nixpkgs.lib.nixosSystem {
				specialArgs = { inherit inputs; };
				modules = [
					./hosts/dobby
					./modules/common
					./modules/server
					sops-nix.nixosModules.sops
					home-manager.nixosModules.home-manager {
						home-manager.useGlobalPkgs = true;
						home-manager.useUserPackages = true;
						home-manager.backupFileExtension = "backup";
						home-manager.extraSpecialArgs = { inherit inputs; };
						home-manager.sharedModules = [ sops-nix.homeManagerModules.sops ];
						home-manager.users.nic = import ./home/server.nix;
					}
				];
			};
		};
	};
}

