{ pkgs, ... }:

{
  programs.wofi = {
    enable = true;
    settings = {
      width = 600;
      height = 400;
      show = "drun";
      prompt = "Search...";
      allow_markup = true;
      insensitive = true;
      matching = "fuzzy";
      term = "ghostty";
    };
    style = ./style.css;
  };
}
