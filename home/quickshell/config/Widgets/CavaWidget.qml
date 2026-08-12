import Quickshell
import Quickshell.Io
import QtQuick
import qs

Widget {
  id: widget
  widthPadding: 8

  property string cavaOutput: ""

  text: cavaOutput

  Process {
    id: proc
    command: ["bash", "-c", (Quickshell.env("QS_CONFIG_PATH") ?? "") + "/scripts/cava.sh"]
    stdout: SplitParser {
      splitMarker: "\n"
      onRead: function(data) {
        cavaOutput = data.trim()
      }
    }
    onRunningChanged: {
      if (!running) restartTimer.start()
    }
  }

  Timer {
    id: restartTimer
    interval: 1000
    onTriggered: proc.running = true
  }

  Component.onCompleted: proc.running = true
  Component.onDestruction: {
    restartTimer.stop()
    proc.running = false
  }
}
