import Quickshell
import Quickshell.Io
import QtQuick
import qs
import qs.Ui
import qs.Commons

BarWidget {
  id: widget

  property int capacity: -1
  property string status: ""
  property real powerRate: 0
  property bool acOnline: false

  moduleName: "quickshell.battery"

  text: {
    if (widget.capacity < 0) return ""
    var pct = widget.capacity
    var idx = Math.min(Math.floor(pct / 10), 9)

    if (widget.status === "Charging") {
      var chargingIcons = ["󰢜", "󰂆", "󰂇", "󰂈", "󰢝", "󰂉", "󰢞", "󰂊", "󰂋", "󰂅"]
      return pct + "% " + chargingIcons[idx]
    }

    if (widget.status === "Not charging") {
      return pct + "% "
    }

    if (widget.status === "Full") {
      return pct + "% 󰂅"
    }

    var dischargingIcons = ["󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"]
    return pct + "% " + dischargingIcons[idx]
  }

  implicitHeight: Constants.barHeight
  implicitWidth: text !== "" ? contentText.implicitWidth + Constants.defaultPadding : 0

  Text {
    id: contentText
    anchors.centerIn: parent
    color: Colors.foreground
    font.family: Constants.fontFamily
    font.pixelSize: Constants.fontSize
    text: widget.text
  }

  Timer {
    id: batteryTimer
    interval: 5000
    running: true
    repeat: true
    onTriggered: pollProc.running = true
  }

  Process {
    id: pollProc
    command: ["bash", "-c", "BAT=$(ls /sys/class/power_supply/ | grep -E '^BAT[0-9]+$' | head -1); if [ -n \"$BAT\" ]; then cap=$(cat /sys/class/power_supply/$BAT/capacity); status=$(cat /sys/class/power_supply/$BAT/status); power=$(cat /sys/class/power_supply/$BAT/power_now 2>/dev/null || echo 0); ac=0; for psu in /sys/class/power_supply/*/online; do if [ \"$(cat $(dirname $psu)/type 2>/dev/null)\" = \"Mains\" ] && [ \"$(cat $psu)\" = \"1\" ]; then ac=1; break; fi; done; echo \"$cap|$status|$ac|$power\"; fi"]
    stdout: StdioCollector { id: batteryCollector }
    onExited: {
      var parts = batteryCollector.text.trim().split("|")
      if (parts.length >= 4) {
        widget.capacity = parseInt(parts[0])
        widget.status = parts[1]
        widget.acOnline = parseInt(parts[2]) === 1
        widget.powerRate = parseFloat(parts[3]) / 1000000.0
      }
    }
  }

  MouseArea {
    id: batteryMouse
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    cursorShape: Qt.PointingHandCursor
    hoverEnabled: true
    onClicked: function(mouse) {
      if (mouse.button === Qt.RightButton) {
        infoProc.command = ["notify-send", "-u", "low", "Battery " + widget.capacity + "% · " + widget.powerRate.toFixed(1) + "W (" + widget.status + ")"]
        infoProc.running = true
      } else {
        menuProc.command = ["quickshell-menu", "system"]
        menuProc.running = true
      }
    }
  }

  StyledTooltip {
    target: widget
    hovered: batteryMouse.containsMouse
    tooltipText: {
      if (widget.status === "Charging") return widget.powerRate > 0 ? "Charging ⚡ " + widget.powerRate.toFixed(1) + "W" : "Charging ⚡"
      if (widget.status === "Discharging") return widget.powerRate > 0 ? "Discharging 🔋 " + widget.powerRate.toFixed(1) + "W" : "Discharging 🔋"
      if (widget.status === "Not charging") return "Plugged in 🔌"
      if (widget.status === "Full") return "Fully charged 🔌"
      return ""
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
