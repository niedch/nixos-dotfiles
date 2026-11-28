{inputs, ...}: {
  perSystem = {pkgs, system, ...}: {
    packages = {
      mux-session = import ../home/tools/mux-session/mux-session.pkg.nix {
        inherit pkgs;
        mux-session = inputs.mux-session.packages.${system}.default;
      };

      opencode = import ../home/agents/opencode/opencode.pkg.nix {
        inherit pkgs;
      };
    };
  };
}
