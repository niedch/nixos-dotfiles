import Quickshell
import Quickshell.Io
import QtQuick

Item {
  implicitHeight: 26
  width: cpuText.implicitWidth + 15

  Text {
    id: cpuText
    anchors.centerIn: parent
    color: "#C5C9C7"
    font.family: "JetBrainsMono Nerd Font"
    font.pixelSize: 12
    text: "󰍛"

    MouseArea {
      anchors.fill: parent
      cursorShape: Qt.PointingHandCursor
      onClicked: {
        btopProc.command = ["ghostty", "--class=org.omarchy.Btop", "-e", "btop"]
        btopProc.running = true
      }
    }
  }

  Process { id: btopProc }
}
