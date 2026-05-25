{
	description = "Multi host Nixos + hyperland config";

	inputs = {
		nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

		home-manager = {
			url = "github:nix-community/home-manager";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		hyprland.url = "github:hyprwm/Hyprland";
	};

	outputs = {self, nixpkgs, home-manager, hyprland, ...  } @ inputs:
		let 
			mkSystem = hostname: system: extraModules:
			nixpkgs.lib.nixosSystem {
				inherit system;
				specialArgs = { inherit inputs; };
				modules = [
				./modules/common
				home-manager.nixosModules.home-manager {
					home-manager.useGlobalPkgs = true;
					home-manager.useUserPackages = true;
					home-manager.extraSpecialArgs = { inherit inputs; };
					home-manager.users.nic = import ./home/common;
				}
				./hosts/${hostname}
				] ++ extraModules;
			};
		in {
			nixosConfiguration = {
				desktop = mkSystem "desktop" "x86_64-linux" [];
			};
		};
}

