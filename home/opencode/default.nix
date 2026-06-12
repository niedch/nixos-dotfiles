{ config, pkgs, ... }:

{


    home.packages = with pkgs; [
        opencode
    ];

    xdg.configFile."opencode/opencode.json".source = ./config/opencode.json;
    xdg.configFile."opencode/tui.json".source = ./config/tui.json;
    xdg.configFile."opencode/prompts/researcher.md".source = ./config/prompts/researcher.md;
}
