import Quickshell
import Quickshell.Io
import QtQuick

Item {
  implicitHeight: 26
  width: updateText.implicitWidth + 15

  Text {
    id: updateText
    anchors.centerIn: parent
    color: "#C5C9C7"
    font.family: "JetBrainsMono Nerd Font"
    font.pixelSize: 10
    text: hasUpdate ? "" : ""
    visible: hasUpdate
  }

  property bool hasUpdate: false

  Timer {
    id: updateTimer
    interval: 21600000
    running: true
    repeat: true
    onTriggered: checkUpdate.running = true
  }

  Process {
    id: checkUpdate
    command: ["bash", "-c", "omarchy-update-available"]
    stdout: StdioCollector { id: updateCollector }
    onExited: {
      var data = updateCollector.text.trim()
      hasUpdate = data.length > 0
    }
  }

  MouseArea {
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    onClicked: {
      updateAction.command = ["omarchy-launch-floating-terminal-with-presentation", "omarchy-update"]
      updateAction.running = true
    }
  }

  Process { id: updateAction }

  Component.onCompleted: checkUpdate.running = true
}
