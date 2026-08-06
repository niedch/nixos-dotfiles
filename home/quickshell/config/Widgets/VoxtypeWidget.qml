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
    command: ["voxtype", "status", "--follow", "--extended", "--format", "json"]
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
        configProc.command = ["ghostty", "--class=org.tui.Voxtype", "-e", "voxtype", "configure"]
      } else {
        configProc.command = ["ghostty", "--class=org.tui.Voxtype", "-e", "voxtype", "setup", "model"]
      }
      configProc.running = true
    }
  }

  Process { id: configProc }
}
