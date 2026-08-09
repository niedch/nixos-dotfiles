{pkgs, ...}: {
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "post-homepage-message-board" ''
      set -euo pipefail

      SERVER="''${MESSAGE_BOARD_HOST:-dobby:8090}"
      HOST="''${MESSAGE_BOARD_SENDER:-$HOSTNAME}"

      usage() {
        echo "Usage: post-homepage-message-board <message> [type]"
        echo ""
        echo "  message   The message text (required)"
        echo "  type      Message type: info (ℹ️), success (✅), warning (⚠️), error (❌)"
        echo ""
        echo "Environment:"
        echo "  MESSAGE_BOARD_HOST    Server address (default: dobby:8090)"
        echo "  MESSAGE_BOARD_SENDER  Sender hostname (default: current hostname)"
        exit 1
      }

      if [ $# -lt 1 ]; then
        usage
      fi

      MESSAGE="$1"
      TYPE="''${2:-info}"

      ${pkgs.curl}/bin/curl -s -X POST "http://$SERVER/" \
        -H "Content-Type: application/json" \
        -d "$(${pkgs.jq}/bin/jq -nc \
          --arg message "$MESSAGE" \
          --arg host "$HOST" \
          --arg type "$TYPE" \
          '{message: $message, host: $host, type: $type}')"

      echo ""
    '')
  ];
}
