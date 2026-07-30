import Quickshell
import Quickshell.Io
import QtQuick

Item {
  implicitHeight: 26
  width: recText.implicitWidth + 5

  Text {
    id: recText
    anchors.centerIn: parent
    color: isRecording ? "#a55555" : "#C5C9C7"
    font.family: "JetBrainsMono Nerd Font"
    font.pixelSize: 10
    text: isRecording ? " REC" : ""
    visible: isRecording
  }

  property bool isRecording: false

  Timer {
    interval: 1000
    running: true
    repeat: true
    onTriggered: checkRec.running = true
  }

  Process {
    id: checkRec
    command: ["bash", "-c", "pgrep -x wf-recorder >/dev/null 2>&1 && echo 'recording' || true"]
    stdout: StdioCollector { id: recCollector }
    onExited: {
      isRecording = recCollector.text.trim() === "recording"
    }
  }

  MouseArea {
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    onClicked: {
      toggleRec.command = ["capture-screenrecord"]
      toggleRec.running = true
    }
  }

  Process { id: toggleRec }
}
