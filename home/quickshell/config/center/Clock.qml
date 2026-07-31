import Quickshell
import Quickshell.Io
import QtQuick
import qs

Widget {
  widthPadding: 17

  text: Qt.formatDateTime(clockSource.date, "dddd HH:mm")

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
