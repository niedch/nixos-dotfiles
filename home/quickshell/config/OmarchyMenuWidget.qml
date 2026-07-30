import Quickshell
import Quickshell.Io
import QtQuick

Item {
  implicitHeight: 26
  width: label.implicitWidth + 15

  Text {
    id: label
    anchors.centerIn: parent
    color: "#C5C9C7"
    font.family: "omarchy"
    font.pixelSize: 14
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
  }

  Process { id: menuProc }
  Process { id: termProc }
}
