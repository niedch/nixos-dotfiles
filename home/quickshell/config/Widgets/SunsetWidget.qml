import QtQuick
import qs

PollingStatusWidget {
  checkCommand: ["bash", "-c", "toggle-sunset --status > /dev/null && echo 'on' || true"]
  activeText: "󰛨"
  toggleCommandWhenActive: ["toggle-sunset", "--off"]
  toggleCommandWhenInactive: ["toggle-sunset", "--on"]
}
