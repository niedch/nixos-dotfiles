{
  config,
  pkgs,
  lib,
  ...
}:
let
  dcalBin = lib.getExe config.programs.dank-calendar.package;
  secretPath = config.sops.secrets.CALENDAR_CONFIG.path;

  syncCalendarScript = pkgs.writeShellScriptBin "dcal-sync-calendar-accounts" ''
    set -euo pipefail

    SECRET_PATH="${secretPath}"
    DCAL="${dcalBin}"
    JQ="${pkgs.jq}/bin/jq"

    if [ ! -r "$SECRET_PATH" ]; then
      echo "dcal-sync-calendar-accounts: secret file '$SECRET_PATH' not readable yet. Skipping."
      exit 0
    fi

    EXISTING_ACCOUNTS=$("$DCAL" account list --json 2>/dev/null || echo "[]")

    add_feed() {
      local name="$1"
      local url="$2"
      [ -z "$url" ] && return 0

      local exists
      exists=$(echo "$EXISTING_ACCOUNTS" | "$JQ" --arg url "$url" --arg name "$name" \
        '[.[] | select((.settings.url? == $url) or (.displayName == $name))] | length')

      if [ "$exists" -gt 0 ]; then
        echo "dcal-sync-calendar-accounts: account for '$name' ($url) already exists. Skipping."
      else
        echo "dcal-sync-calendar-accounts: adding ical account '$name' ($url)..."
        if "$DCAL" account add ical "$url" --name "$name"; then
          echo "dcal-sync-calendar-accounts: successfully added '$name'."
        else
          echo "dcal-sync-calendar-accounts: warning: failed to add '$url' (network offline?)." >&2
        fi
      fi
    }

    # Case 1: JSON array of objects: [ {"name": "...", "url": "..."}, ... ]
    if "$JQ" -e 'type == "array"' "$SECRET_PATH" >/dev/null 2>&1; then
      "$JQ" -c '.[]' "$SECRET_PATH" | while read -r item; do
        NAME=$(echo "$item" | "$JQ" -r '.name // "Personal"')
        URL=$(echo "$item" | "$JQ" -r '.url // empty')
        add_feed "$NAME" "$URL"
      done
    # Case 2: JSON object: { "Personal": "https://...", "Work": "https://..." }
    elif "$JQ" -e 'type == "object"' "$SECRET_PATH" >/dev/null 2>&1; then
      "$JQ" -r 'to_entries[] | "\(.key)\t\(.value)"' "$SECRET_PATH" | while IFS=$'\t' read -r NAME URL; do
        add_feed "$NAME" "$URL"
      done
    # Case 3: Plain text (one URL per line or raw string)
    else
      while IFS= read -r line || [ -n "$line" ]; do
        URL=$(echo "$line" | ${pkgs.gnugrep}/bin/grep -oE '(https?|webcal)://[^"'\'''\r\n <>]+' || true)
        if [ -n "$URL" ]; then
          add_feed "Personal" "$URL"
        fi
      done < "$SECRET_PATH"
    fi
  '';
in
{
  sops.secrets.CALENDAR_CONFIG = {};

  home.packages = [ syncCalendarScript ];

  systemd.user.services.dcal-sync-calendar-accounts = {
    Unit = {
      Description = "Sync calendar accounts from SOPS secret to dcal";
      After = [ "sops-nix.service" ];
      Wants = [ "sops-nix.service" ];
      PartOf = [ config.programs.dank-calendar.systemd.target ];
    };

    Service = {
      Type = "oneshot";
      ExecStart = "${lib.getExe syncCalendarScript}";
      RemainAfterExit = true;
    };

    Install = {
      WantedBy = [ config.programs.dank-calendar.systemd.target ];
    };
  };

  home.activation.dcalSyncAccounts = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if [ -r "${secretPath}" ]; then
      ${lib.getExe syncCalendarScript} || true
    fi
  '';
}
