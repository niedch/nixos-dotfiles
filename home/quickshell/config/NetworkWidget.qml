import Quickshell
import Quickshell.Networking
import Quickshell.Io
import QtQuick

Item {
  id: root

  width: textItem.implicitWidth + 16
  implicitHeight: 26

  Text {
    id: textItem
    anchors.centerIn: parent
    color: "#C5C9C7"
    font.family: "JetBrainsMono Nerd Font"
    font.pixelSize: 12
    text: {
      if (Networking.connectivity === NetworkConnectivity.Full) {
        for (var i = 0; i < Networking.devices.count; i++) {
          var dev = Networking.devices.get(i)
          if (dev.type === DeviceType.WiFi && dev.state === ConnectionState.Activated) {
            var strength = dev.strength
            if (strength > 75) return "󰤨"
            if (strength > 50) return "󰤥"
            if (strength > 25) return "󰤢"
            if (strength > 10) return "󰤟"
            return "󰤯"
          }
          if (dev.type === DeviceType.Ethernet && dev.state === ConnectionState.Activated) {
            return "󰀂"
          }
        }
        return "󰤨"
      }
      return "󰤮"
    }
  }

  MouseArea {
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    onClicked: {
      netProc.command = ["ghostty", "--class=org.omarchy.wlctl", "-e", "wlctl"]
      netProc.running = true
    }
  }

  Process {
    id: netProc
  }
}
