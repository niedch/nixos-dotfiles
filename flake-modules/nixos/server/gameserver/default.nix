{config, ...}: {
  flake.modules.nixos.server-gameserver = {...}: {
    imports = with config.flake.modules.nixos; [
      server-gameserver-steam
      server-gameserver-valheim
    ];
  };
}
