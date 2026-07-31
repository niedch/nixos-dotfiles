import Quickshell
import Quickshell.Io
import QtQuick

Item {
  implicitHeight: 26
  width: cavaText.implicitWidth + 8

  Text {
    id: cavaText
    anchors.centerIn: parent
    color: "#C5C9C7"
    font.family: "JetBrainsMono Nerd Font"
    font.pixelSize: 12
    text: cavaOutput
  }

  property string cavaOutput: ""

  Process {
    id: proc
    command: ["bash", "-c", "./cava.sh"]
    running: true
    stdout: SplitParser {
      splitMarker: "\n"
      onRead: function(data) {
        var line = data.trim()
        if (line !== "") {
          cavaOutput = line
        }
      }
    }
  }
}
