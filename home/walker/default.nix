{ pkgs, ... }:

{
  home.packages = [ pkgs.walker pkgs.elephant ];

  xdg.configFile."walker/config.toml".source = ./config.toml;
  xdg.configFile."walker/themes/kanso/layout.xml".source = ./kanso-layout.xml;

  xdg.configFile."elephant/calc.toml".source = ./elephant/calc.toml;
  xdg.configFile."elephant/desktopapplications.toml".source = ./elephant/desktopapplications.toml;
  xdg.configFile."elephant/symbols.toml".source = ./elephant/symbols.toml;

  xdg.configFile."elephant/menus/omarchy_background_selector.lua".text = ''
    Name = "omarchyBackgroundSelector"
    NamePretty = "Omarchy Background Selector"
    Cache = false
    HideFromProviderlist = true
    SearchName = true

    function GetEntries()
      return {
        {
          Text = "Kanso 1",
          Value = "/dev/null",
        },
        {
          Text = "Kanso 2",
          Value = "/dev/null",
        },
      }
    end
  '';

  xdg.configFile."elephant/menus/omarchy_themes.lua".text = ''
    Name = "omarchythemes"
    NamePretty = "Omarchy Themes"
    HideFromProviderlist = true
    SearchName = true

    function GetEntries()
      return {
        {
          Text = "Kanso  ",
          Value = "kanso",
          Actions = {
            activate = "echo 'Theme switching not wired yet'",
          },
        },
      }
    end
  '';

  xdg.configFile."elephant/menus/omarchy_unlocks.lua".text = ''
    Name = "omarchyunlocks"
    NamePretty = "Omarchy Unlocks"
    HideFromProviderlist = true
    FixedOrder = true

    function GetEntries()
      return {
        {
          Text = "Default  ",
          Actions = {
            activate = "notify-send 'Unlock themes not wired yet'",
          },
        },
      }
    end
  '';
}
