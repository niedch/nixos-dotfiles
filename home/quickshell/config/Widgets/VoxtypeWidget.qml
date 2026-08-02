import Quickshell
import Quickshell.Io
import QtQuick
import qs

Widget {
  widthPadding: 15

  property string voxtypeIcon: ""
  property string stateClass: ""

  text: voxtypeIcon
  textColor: stateClass === "recording" || stateClass === "transcribing" ? Colors.color1 : Colors.foreground
  textVisible: voxtypeIcon !== ""

  Process {
    id: voxtypeProc
    command: ["omarchy-voxtype-status"]
    running: true
    stdout: SplitParser {
      splitMarker: "\n"
      onRead: function(data) {
        try {
          var obj = JSON.parse(data)
          voxtypeIcon = obj.text || ""
          stateClass = obj.class || ""
        } catch (e) {}
      }
    }
  }

  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    cursorShape: Qt.PointingHandCursor
    onClicked: function(mouse) {
      if (mouse.button === Qt.RightButton) {
        configProc.command = ["omarchy-voxtype-config"]
      } else {
        configProc.command = ["omarchy-voxtype-model"]
      }
      configProc.running = true
    }
  }

  Process { id: configProc }
}
