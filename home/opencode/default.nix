{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.opencode-waybar-status.homeModules.default
  ];

  programs.opencode-waybar-status = {
    enable = true;
    package = inputs.opencode-waybar-status.packages.${pkgs.system}.default;
  };

  home.packages = with pkgs; [
    opencode
  ];

  xdg.configFile."opencode/opencode.json".source = ./config/opencode.json;
  xdg.configFile."opencode/tui.json".source = ./config/tui.json;
  xdg.configFile."opencode/prompts/researcher.md".source = ./config/prompts/researcher.md;
  xdg.configFile."opencode/prompts/pr-summarizer.md".source = ./config/prompts/pr-summarizer.md;
  xdg.configFile."opencode/prompts/willhaben-agent.md".source = ./config/prompts/willhaben-agent.md;
}
