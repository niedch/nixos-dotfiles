import Quickshell
import Quickshell.Bluetooth
import Quickshell.Io
import QtQuick

Item {
  id: root

  width: textItem.implicitWidth + 16
  implicitHeight: 26

  readonly property var adapter: Bluetooth.defaultAdapter

  Text {
    id: textItem
    anchors.centerIn: parent
    color: "#C5C9C7"
    font.family: "JetBrainsMono Nerd Font"
    font.pixelSize: 12
    text: {
      if (!root.adapter || !root.adapter.powered) return "󰂲"
      if (Bluetooth.devices.count > 0) return "󰂱"
      return ""
    }
  }

  MouseArea {
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    onClicked: {
      btProc.command = ["ghostty", "--class=org.omarchy.Bluetui", "-e", "bluetui"]
      btProc.running = true
    }
  }

  Process {
    id: btProc
  }
}
