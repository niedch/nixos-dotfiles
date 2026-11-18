{config, ...}: {
  sops.secrets.noctalia_calendars = {
    path = "${config.home.homeDirectory}/.config/noctalia/z-calendars.toml";
    mode = "0600";
  };
}
