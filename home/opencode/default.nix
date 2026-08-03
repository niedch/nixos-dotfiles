{pkgs, ...}: {
  home.packages = with pkgs; [
    opencode
  ];

  xdg.configFile."opencode/opencode.jsonc".source = ./config/opencode.jsonc;
  xdg.configFile."opencode/tui.json".source = ./config/tui.json;
  xdg.configFile."opencode/prompts/researcher.md".source = ./config/prompts/researcher.md;
  xdg.configFile."opencode/prompts/orchestrator.md".source = ./config/prompts/orchestrator.md;
  xdg.configFile."opencode/prompts/pr-summarizer.md".source = ./config/prompts/pr-summarizer.md;
  xdg.configFile."opencode/prompts/willhaben-agent.md".source = ./config/prompts/willhaben-agent.md;
}
