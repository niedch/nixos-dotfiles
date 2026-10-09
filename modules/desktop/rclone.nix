{
  config,
  pkgs,
  lib,
  ...
}: let
  mounts = [
    {
      name = "G-Drive";
      remote = "G-Drive:Documents";
      mountPoint = "/media/Google-Drive";
    }
    {
      name = "I-Cloud";
      remote = "Icloud:";
      mountPoint = "/media/ICloud";
    }
    {
      name = "Dropbox";
      remote = "Dropbox:";
      mountPoint = "/media/Dropbox";
    }
  ];

  # network-online.target only guarantees an interface is up, not that DNS
  # resolution works. rclone's first action is an OAuth token refresh that
  # fails with "no such host" if name resolution isn't ready yet (e.g. right
  # after NetworkManager is restarted during a switch), so wait until it is.
  waitForDns = pkgs.writeShellApplication {
    name = "rclone-wait-for-dns";
    runtimeInputs = [
      pkgs.getent
      pkgs.coreutils
    ];
    text = ''
      i=0
      while [ "$i" -lt 90 ]; do
        if getent ahosts oauth2.googleapis.com >/dev/null 2>&1; then
          exit 0
        fi
        sleep 1
        i=$((i + 1))
      done
      echo "rclone-wait-for-dns: DNS still unavailable after 90s" >&2
      exit 1
    '';
  };

  rcloneReauthIcloud = pkgs.writeShellApplication {
    name = "rclone-reauth-icloud";
    runtimeInputs = [
      pkgs.sops
      pkgs.jq
      pkgs.rclone
      pkgs.coreutils
      pkgs.git
      pkgs.systemd
    ];
    text = ''
      show_help() {
        cat << 'HELP'
      Usage: rclone-reauth-icloud [OPTIONS]

      Helper to re-authenticate the iCloud rclone remote when the Apple trust token
      expires (~every 30 days) and update the encrypted SOPS secret in the dotfiles repo.

      Options:
        -h, --help    Show this help message
        -e, --edit    Open interactive rclone config editor instead of reconnecting
                      (useful if Apple ID password or other settings changed)
      HELP
      }

      if [ "''${1:-}" = "-h" ] || [ "''${1:-}" = "--help" ]; then
        show_help
        exit 0
      fi

      # Set age key file if present and not already configured
      if [ -z "''${SOPS_AGE_KEY_FILE:-}" ] && [ -f "$HOME/.config/sops/age/keys.txt" ]; then
        export SOPS_AGE_KEY_FILE="$HOME/.config/sops/age/keys.txt"
      fi

      # Locate repository containing secrets
      REPO_DIR=""
      if [ -n "''${DOTFILES_DIR:-}" ] && [ -f "''${DOTFILES_DIR}/secrets/secrets.yaml" ]; then
        REPO_DIR="$DOTFILES_DIR"
      elif [ -f "$PWD/secrets/secrets.yaml" ]; then
        REPO_DIR="$PWD"
      elif [ -f "$HOME/Projects/nixos-dotfiles/secrets/secrets.yaml" ]; then
        REPO_DIR="$HOME/Projects/nixos-dotfiles"
      else
        echo "Error: Could not find secrets/secrets.yaml" >&2
        echo "Run this command from within the dotfiles repository or set DOTFILES_DIR." >&2
        exit 1
      fi

      SECRETS_FILE="$REPO_DIR/secrets/secrets.yaml"

      # Create secure temporary config file in user runtime memory (RAM)
      RUNTIME_DIR="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
      TEMP_CONF="$RUNTIME_DIR/rclone-reauth-temp.conf"
      rm -f "$TEMP_CONF"

      cleanup() {
        if [ -f "$TEMP_CONF" ]; then
          rm -f "$TEMP_CONF"
        fi
      }
      trap cleanup EXIT INT TERM

      echo "1. Decrypting rclone configuration from SOPS..."
      sops -d --extract '["rclone-config"]' "$SECRETS_FILE" > "$TEMP_CONF"
      chmod 600 "$TEMP_CONF"

      if [ "''${1:-}" = "--edit" ] || [ "''${1:-}" = "-e" ]; then
        echo "2. Opening interactive rclone configuration..."
        rclone config --config "$TEMP_CONF"
      else
        echo "2. Reconnecting Icloud remote via rclone..."
        echo "   (Apple will send a 2FA prompt to your Apple devices or phone)"
        echo ""
        rclone config reconnect Icloud: --config "$TEMP_CONF"
      fi

      echo ""
      echo "3. Verifying iCloud connection..."
      if rclone lsd Icloud: --config "$TEMP_CONF" >/dev/null 2>&1; then
        echo "   iCloud connection verified successfully!"
      else
        echo "   Error: Failed to connect to iCloud with updated credentials." >&2
        exit 1
      fi

      echo ""
      echo "4. Updating encrypted secrets in $SECRETS_FILE..."
      sops set "$SECRETS_FILE" '["rclone-config"]' "$(jq -Rs . < "$TEMP_CONF")"

      if command -v git >/dev/null 2>&1 && git -C "$REPO_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        git -C "$REPO_DIR" add "$SECRETS_FILE"
        echo "   Staged $SECRETS_FILE in git repository."
      fi

      echo ""
      read -r -p "Apply updated configuration to running system immediately with sudo? [y/N] " response
      case "$response" in
        [yY][eE][sS]|[yY])
          if [ -d "/run/secrets" ]; then
            sudo install -m 0400 -o root -g root "$TEMP_CONF" /run/secrets/rclone-config
            sudo systemctl restart rclone-mount-I-Cloud.service
            echo "   Restarted rclone-mount-I-Cloud.service."
            systemctl status rclone-mount-I-Cloud.service --no-pager || true
          fi
          ;;
        *)
          echo "   Skipped live restart."
          ;;
      esac

      echo ""
      echo "Finished! Remember to rebuild or switch when convenient to persist in NixOS:"
      echo "  mise run switch desktop"
    '';
  };
in
  lib.mkIf config.sops.enable {
    environment.systemPackages = [
      pkgs.rclone
      rcloneReauthIcloud
    ];

    systemd.services = builtins.listToAttrs (map (mount: {
        name = "rclone-mount-${mount.name}";
        value = {
          description = "rclone mount service (${mount.name})";
          after = ["network-online.target"];
          wants = ["network-online.target"];
          wantedBy = ["multi-user.target"];

          serviceConfig = {
            Type = "simple";
            ExecStartPre = [
              "${pkgs.coreutils}/bin/mkdir -p ${mount.mountPoint}"
              "${lib.getExe waitForDns}"
            ];
            ExecStart = "${pkgs.rclone}/bin/rclone mount ${mount.remote} ${mount.mountPoint} --config ${config.sops.secrets.rclone-config.path} --allow-other --vfs-cache-mode writes --dir-perms 0755 --file-perms 0644";
            ExecStop = "${pkgs.fuse3}/bin/fusermount3 -u ${mount.mountPoint}";
            Restart = "on-failure";
            RestartSec = "10s";
            TimeoutStartSec = "120s";
          };
        };
      })
      mounts);
  }
