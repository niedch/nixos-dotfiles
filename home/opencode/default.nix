{ config, pkgs, ... }:

{
    xdg.configFile."opencode/opencode.json".source = ./config/opencode.json;
    xdg.configFile."opencode/prompts/researcher.md".source = ./config/prompts/researcher.md;
}
