{...}: {
  flake.modules.homeManager.home-media-docs-obsidian = {pkgs, ...}: {
    home.packages = with pkgs; [
      obsidian
    ];
  };
}
