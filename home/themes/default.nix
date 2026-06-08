{ inputs, ... }:

{
  imports = [ inputs.nix-omarchy-theme.homeManagerModules.default ];

  omarchy-themes = {
    enable = true;
    defaultTheme = "kanso";

    themes = {
      kanso = {
        url = "https://github.com/HANCORE-linux/omarchy-kanso-theme.git";
        ref = "main";
      };
    };

    symlinks = {
      "hypr/theme.lua".source = "hyprland.lua";
      "hypr/hyprlock.conf".source = "hyprlock.conf";
      "waybar/colors.css".source = "waybar.css";
    };
  };
}
