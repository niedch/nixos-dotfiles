import QtQuick
import qs.Ui

PollingStatusWidget {
  moduleName: "quickshell.sunset"
  checkCommand: ["bash", "-c", "toggle-sunset --status > /dev/null && echo 'on' || true"]
  activeText: "󰛨"
  toggleCommandWhenActive: ["toggle-sunset", "--off"]
  toggleCommandWhenInactive: ["toggle-sunset", "--on"]
}
