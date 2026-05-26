{
	description = "Multi host Nixos + hyperland config";

	inputs = {
		nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

		home-manager = {
			url = "github:nix-community/home-manager/release-25.11";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		hyprland.url = "github:hyprwm/Hyprland";
	};

	outputs = {self, nixpkgs, home-manager, hyprland, ...  } @ inputs: {
		nixosConfigurations = {
			 desktop = nixpkgs.lib.nixosSystem {
				system = "x86_64-linux";
				specialArgs = { inherit inputs; };
        modules = [
          ./hosts/desktop
          ./modules/common
          home-manager.nixosModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs; };
            home-manager.users.nic = import ./home/common/default.nix;
          }
        ];
			};
		};
	};
}

