{config, pkgs, ...}: {
  home.packages = [pkgs.obsidian];

  home.file."Projects/obsidian-vault/.obsidian/snippets/obsidian.css" = {
    source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/.themes-src/current/obsidian.css";
  };
}
