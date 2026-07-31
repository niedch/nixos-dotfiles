import QtQuick
import qs

PollingStatusWidget {
  checkCommand: ["bash", "-c", "makoctl mode | grep -q 'do-not-disturb' && echo 'dnd' || true"]
  activeText: "󰂛"
  toggleCommand: ["makoctl", "mode", "-t", "do-not-disturb"]
}
