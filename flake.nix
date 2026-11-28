{
  description = "Multi-host NixOS dotfiles and configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    import-tree.url = "github:denful/import-tree";

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

    nix-lazy-apps = {
      url = "github:niedch/nix-lazy-apps";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dms = {
      url = "github:duxlabs-dev/dux-shell/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dms-plugin-registry = {
      url = "github:duxlabs-dev/dux-plugin-registry";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dux-calendar = {
      url = "github:duxlabs-dev/dux-calendar";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dux-greeter = {
      url = "github:duxlabs-dev/dux-greeter";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs: let
    lib = inputs.nixpkgs.lib;
  in
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = ["x86_64-linux"];

      imports = [
        # Excluded from import-tree by the default `/_` filter.
        ./flake-modules/_lib

        # Everything else under flake-modules/ is a top-level flake-parts module.
        (inputs.import-tree.filterNot
          (lib.hasSuffix ".pkg.nix")
          ./flake-modules)
      ];

      # Available to _lib and to all auto-imported top-level modules.
      _module.args.rootPath = ./.;
    };
}
