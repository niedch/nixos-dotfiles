import Quickshell
import Quickshell.Io
import QtQuick
import qs

Widget {
  id: widget

  property int capacity: -1
  property string status: ""

  text: {
    if (widget.capacity < 0) return ""
    var pct = widget.capacity
    var idx = Math.min(Math.floor(pct / 10), 9)

    if (widget.status === "Full" || widget.status === "Not charging") {
      return pct + "% "
    }

    if (widget.status === "Charging") {
      var chargingIcons = ["󰢜", "󰂆", "󰂇", "󰂈", "󰢝", "󰂉", "󰢞", "󰂊", "󰂋", "󰂅"]
      return pct + "% " + chargingIcons[idx]
    }

    var dischargingIcons = ["󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"]
    return pct + "% " + dischargingIcons[idx]
  }

  Timer {
    id: batteryTimer
    interval: Constants.pollSlow
    running: true
    repeat: true
    onTriggered: pollProc.running = true
  }

  Process {
    id: pollProc
    command: ["bash", "-c", "BAT=$(ls /sys/class/power_supply/ | grep -E '^BAT[0-9]+$' | head -1); if [ -n \"$BAT\" ]; then echo \"$(cat /sys/class/power_supply/$BAT/capacity) $(cat /sys/class/power_supply/$BAT/status)\"; fi"]
    stdout: StdioCollector { id: batteryCollector }
    onExited: {
      var parts = batteryCollector.text.trim().split(/\s+/)
      if (parts.length >= 2) {
        widget.capacity = parseInt(parts[0])
        widget.status = parts[1]
      }
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
        menuProc.command = ["omarchy-menu", "power"]
        menuProc.running = true
      }
    }
  }

  Process {
    id: menuProc
  }

  Process {
    id: infoProc
  }

  Component.onCompleted: pollProc.running = true
}
