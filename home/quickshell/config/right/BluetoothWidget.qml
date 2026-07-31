import Quickshell
import Quickshell.Bluetooth
import Quickshell.Io
import QtQuick
import qs

Widget {
  text: {
    if (!Bluetooth.defaultAdapter || !Bluetooth.defaultAdapter.enabled) return "󰂲"
    if (Bluetooth.devices.values.length > 0) return "󰂱"
    return ""
  }

  MouseArea {
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    onClicked: {
      btProc.command = ["ghostty", "--class=org.tui.Bluetui", "-e", "bluetui"]
      btProc.running = true
    }
  }

  Process {
    id: btProc
  }
}
