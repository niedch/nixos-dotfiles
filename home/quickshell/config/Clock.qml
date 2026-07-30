import Quickshell
import Quickshell.Io
import QtQuick

Item {
  implicitHeight: 26
  width: clockText.implicitWidth + 17

  Text {
    id: clockText
    anchors.centerIn: parent
    color: "#C5C9C7"
    font.family: "JetBrainsMono Nerd Font"
    font.pixelSize: 12
    text: Qt.formatDateTime(clockSource.date, "dddd HH:mm")
  }

  SystemClock {
    id: clockSource
    precision: SystemClock.Minutes
  }

  MouseArea {
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    onClicked: {
      calendarProc.command = ["chromium", "--app=https://calendar.google.com/calendar/u/0/r/month"]
      calendarProc.running = true
    }
  }

  Process {
    id: calendarProc
  }
}
