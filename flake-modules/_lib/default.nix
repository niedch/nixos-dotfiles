{
  lib,
  inputs,
  rootPath,
  ...
}:
let
  inherit (inputs) nixpkgs home-manager sops-nix;
in
{
  options.flake.modules = lib.mkOption {
    type = lib.types.lazyAttrsOf (lib.types.lazyAttrsOf lib.types.deferredModule);
    default = { };
    description = ''
      Lower-level modules, grouped by module class (`nixos`, `homeManager`, ...).
      Set `flake.modules.<class>.<name>` from any top-level module.
    '';
  };

  config._module.args.mkNixosSystem = {
    modules,
    home ? null,
    user ? "nic",
    extraSpecialArgs ? { },
  }:
    nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs rootPath;
      } // extraSpecialArgs;

      modules =
        modules
        ++ [
          sops-nix.nixosModules.sops
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.extraSpecialArgs = {
              inherit inputs rootPath;
            };
            home-manager.sharedModules = [ sops-nix.homeManagerModules.sops ];
          }
        ]
        ++ lib.optional (home != null) {
          home-manager.users.${user} = {
            imports = lib.toList home;
          };
        };
    };
}
