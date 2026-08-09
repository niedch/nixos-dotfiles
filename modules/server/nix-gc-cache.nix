{...}: {
  systemd.timers.nix-cache-gc = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
      RandomizedDelaySec = "1h";
    };
  };

  systemd.services.nix-cache-gc = {
    after = ["mnt-hdd.mount"];
    requires = ["mnt-hdd.mount"];
    serviceConfig.Type = "oneshot";
    script = ''
      STORE=/mnt/hdd/nix

      mkdir -p "$STORE/var/nix/gcroots/auto"
      nix-store --store "$STORE" -qR --all > "$STORE/var/nix/gcroots/auto/cache-keep"

      find "$STORE/store" -type f -atime +5 -delete 2>/dev/null || true
      find "$STORE/store" -type d -empty -delete 2>/dev/null || true

      nix-store --store "$STORE" --gc

      rm -f "$STORE/var/nix/gcroots/auto/cache-keep"
    '';
  };
}
