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
    running: true
    stdout: SplitParser {
      splitMarker: "\n"
      onRead: function(data) {
        cavaOutput = data.trim()
      }
    }
  }
}
