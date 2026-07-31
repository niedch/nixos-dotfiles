import Quickshell
import Quickshell.Io
import QtQuick
import qs

Widget {
  widthPadding: 15
  fontFamily: "omarchy"
  text: "\ue900"

  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    cursorShape: Qt.PointingHandCursor
    onClicked: function(mouse) {
      if (mouse.button === Qt.RightButton) {
        termProc.command = ["xdg-terminal-exec"]
        termProc.running = true
      } else {
        menuProc.command = ["omarchy-menu"]
        menuProc.running = true
      }
    }
  }

  Process { id: menuProc }
  Process { id: termProc }
}
