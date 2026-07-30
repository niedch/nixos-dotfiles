import Quickshell
import Quickshell.Services.UPower
import Quickshell.Io
import QtQuick

Item {
  id: root

  width: textItem.implicitWidth + 16
  implicitHeight: 26

  readonly property var battery: {
    for (var i = 0; i < UPower.devices.count; i++) {
      var dev = UPower.devices.get(i)
      if (dev.type === UPowerDeviceType.Battery) {
        return dev
      }
    }
    return null
  }

  Text {
    id: textItem
    anchors.centerIn: parent
    color: {
      if (!root.battery) return "#C5C9C7"
      var pct = Math.round(root.battery.percentage)
      if (pct <= 10) return "#a55555"
      if (pct <= 20) return "#a55555"
      return "#C5C9C7"
    }
    font.family: "JetBrainsMono Nerd Font"
    font.pixelSize: 12
    text: {
      if (!root.battery) return ""
      var pct = Math.round(root.battery.percentage)
      var idx = Math.min(Math.floor(pct / 10), 9)

      if (root.battery.state === UPowerDeviceState.FullyCharged) {
        return pct + "% "
      }

      if (root.battery.state === UPowerDeviceState.Charging) {
        var chargingIcons = ["󰢜", "󰂆", "󰂇", "󰂈", "󰢝", "󰂉", "󰢞", "󰂊", "󰂋", "󰂅"]
        return pct + "% " + chargingIcons[idx]
      }

      var dischargingIcons = ["󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"]
      return pct + "% " + dischargingIcons[idx]
    }
  }

  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    cursorShape: Qt.PointingHandCursor
    onClicked: function(mouse) {
      if (mouse.button === Qt.RightButton) {
        infoProc.command = ["bash", "-c", "notify-send -u low \"$(omarchy-battery-status)\""]
        infoProc.running = true
      } else {
        batteryProc.command = ["omarchy-menu", "power"]
        batteryProc.running = true
      }
    }
  }

  Process {
    id: batteryProc
  }

  Process {
    id: infoProc
  }
}
