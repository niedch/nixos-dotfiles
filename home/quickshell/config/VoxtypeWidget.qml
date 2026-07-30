import Quickshell
import Quickshell.Io
import QtQuick

Item {
  implicitHeight: 26
  width: voxtypeText.implicitWidth + 15

  Text {
    id: voxtypeText
    anchors.centerIn: parent
    color: stateClass === "recording" || stateClass === "transcribing" ? "#a55555" : "#C5C9C7"
    font.family: "JetBrainsMono Nerd Font"
    font.pixelSize: 12
    text: voxtypeIcon
    visible: voxtypeIcon !== ""
  }

  property string voxtypeIcon: ""
  property string stateClass: ""

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
