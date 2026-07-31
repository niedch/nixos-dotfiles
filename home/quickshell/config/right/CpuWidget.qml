import Quickshell
import Quickshell.Io
import QtQuick
import qs

Widget {
  widthPadding: 15
  text: "󰍛"

  MouseArea {
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    onClicked: {
      btopProc.command = ["ghostty", "--class=org.omarchy.Btop", "-e", "btop"]
      btopProc.running = true
    }
  }

  Process { id: btopProc }
}
