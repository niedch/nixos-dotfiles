import QtQuick
import qs

PollingStatusWidget {
  invertResult: true
  checkCommand: ["bash", "-c", "pgrep -x hypridle >/dev/null 2>&1 && echo 'running' || true"]
  activeText: "󱫖"
  toggleCommandWhenActive: ["uwsm-app", "--", "hypridle"]
  toggleCommandWhenInactive: ["pkill", "-x", "hypridle"]
}
