import Quickshell
import Quickshell.Io
import QtQuick
import qs
import qs.Ui
import qs.Commons

BarWidget {
  id: widget
  moduleName: "quickshell.voxtype"

  property int widthPadding: 15
  property string voxtypeIcon: ""
  property string stateClass: ""

  text: voxtypeIcon
  textVisible: voxtypeIcon !== ""
  textColor: stateClass === "recording" || stateClass === "transcribing" ? Color.urgent : Color.foreground

  implicitHeight: Constants.barHeight
  implicitWidth: textVisible ? contentText.implicitWidth + widthPadding : 0

  Text {
    id: contentText
    anchors.centerIn: parent
    color: widget.textColor
    font.family: Constants.fontFamily
    font.pixelSize: Constants.fontSize
    text: widget.text
  }

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
