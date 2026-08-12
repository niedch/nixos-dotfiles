import Quickshell
import Quickshell.Io
import QtQuick
import qs

Widget {
  id: widget

  property real cpuUsage: 0
  property real load1: 0
  property real load5: 0
  property real load15: 0

  text: "󰍛"

  Timer {
    id: cpuTimer
    interval: Constants.pollNormal
    running: true
    repeat: true
    onTriggered: pollProc.running = true
  }

  Process {
    id: pollProc
    command: ["bash", "-c", (Quickshell.env("QS_CONFIG_PATH") ?? "") + "/scripts/cpu.sh"]
    stdout: StdioCollector { id: cpuCollector }
    onExited: {
      var parts = cpuCollector.text.trim().split("|")
      if (parts.length >= 4) {
        widget.cpuUsage = parseFloat(parts[0])
        widget.load1 = parseFloat(parts[1])
        widget.load5 = parseFloat(parts[2])
        widget.load15 = parseFloat(parts[3])
      }
    }
  }

  MouseArea {
    id: cpuMouse
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    hoverEnabled: true
    onClicked: {
      btopProc.command = ["ghostty", "--class=org.tui.Btop", "-e", "btop"]
      btopProc.running = true
    }
  }

  StyledTooltip {
    target: widget
    hovered: cpuMouse.containsMouse
    tooltipText: {
      if (widget.cpuUsage <= 0) return ""
      return "CPU " + widget.cpuUsage.toFixed(1) + "%\n" +
        "Load " + widget.load1.toFixed(2) + " " + widget.load5.toFixed(2) + " " + widget.load15.toFixed(2)
    }
  }

  Process { id: btopProc }

  Component.onCompleted: pollProc.running = true
}
