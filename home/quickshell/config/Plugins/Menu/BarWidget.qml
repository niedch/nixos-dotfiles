import Quickshell
import Quickshell.Io
import QtQuick
import qs
import qs.Ui
import qs.Commons

BarWidget {
  id: widget
  moduleName: "quickshell.menu"

  property int widthPadding: 15
  property string fontFamily: "omarchy"

  text: "\ue900"
  textVisible: text !== ""

  implicitHeight: Constants.barHeight
  implicitWidth: textVisible ? contentText.implicitWidth + widthPadding : 0

  Text {
    id: contentText
    anchors.centerIn: parent
    color: Color.foreground
    font.family: widget.fontFamily
    font.pixelSize: Constants.fontSize
    text: widget.text
    visible: widget.textVisible
  }

  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    cursorShape: Qt.PointingHandCursor
    onClicked: function(mouse) {
      if (mouse.button === Qt.RightButton) {
        termProc.command = ["xdg-terminal-exec"]
        termProc.running = true
      } else {
        menuProc.command = ["quickshell-menu", "toggle"]
        menuProc.running = true
      }
    }
  }

  Process { id: termProc }
  Process { id: menuProc }
}
