import Quickshell
import Quickshell.Io
import QtQuick

Item {
  implicitHeight: 26
  width: idleText.implicitWidth + 5

  Text {
    id: idleText
    anchors.centerIn: parent
    color: !isIdleRunning ? "#a55555" : "#C5C9C7"
    font.family: "JetBrainsMono Nerd Font"
    font.pixelSize: 10
    text: !isIdleRunning ? "󱫖" : ""
    visible: !isIdleRunning
  }

  property bool isIdleRunning: false

  Timer {
    interval: 5000
    running: true
    repeat: true
    onTriggered: checkIdle.running = true
  }

  Process {
    id: checkIdle
    command: ["bash", "-c", "pgrep -x hypridle >/dev/null 2>&1 && echo 'running' || true"]
    stdout: StdioCollector { id: idleCollector }
    onExited: {
      isIdleRunning = idleCollector.text.trim() === "running"
    }
  }

  MouseArea {
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    onClicked: {
      if (isIdleRunning) {
        toggleCmd.command = ["pkill", "-x", "hypridle"]
      } else {
        toggleCmd.command = ["uwsm-app", "--", "hypridle"]
      }
      toggleCmd.running = true
      checkIdle.running = true
    }
  }

  Process { id: toggleCmd }

  Component.onCompleted: checkIdle.running = true
}
