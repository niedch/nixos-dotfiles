import Quickshell
import Quickshell.Io
import QtQuick

Item {
  implicitHeight: 26
  width: dndText.implicitWidth + 5

  Text {
    id: dndText
    anchors.centerIn: parent
    color: isDndActive ? "#a55555" : "#C5C9C7"
    font.family: "JetBrainsMono Nerd Font"
    font.pixelSize: 10
    text: isDndActive ? "󰂛" : ""
    visible: isDndActive
  }

  property bool isDndActive: false

  Timer {
    interval: 5000
    running: true
    repeat: true
    onTriggered: checkDnd.running = true
  }

  Process {
    id: checkDnd
    command: ["bash", "-c", "makoctl mode | grep -q 'do-not-disturb' && echo 'dnd' || true"]
    stdout: StdioCollector { id: dndCollector }
    onExited: {
      isDndActive = dndCollector.text.trim() === "dnd"
    }
  }

  MouseArea {
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    onClicked: {
      toggleDnd.command = ["makoctl", "mode", "-t", "do-not-disturb"]
      toggleDnd.running = true
      checkDnd.running = true
    }
  }

  Process { id: toggleDnd }

  Component.onCompleted: checkDnd.running = true
}
