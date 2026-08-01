import Quickshell
import QtQuick
import qs
import qs.Components.Calendar

Widget {
  id: clock
  widthPadding: 17

  text: Qt.formatDateTime(clockSource.date, "dddd HH:mm")

  SystemClock {
    id: clockSource
    precision: SystemClock.Minutes
  }

  MouseArea {
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    onClicked: calendarPopup.toggle()
  }

  CalendarPopup {
    id: calendarPopup
    target: clock
  }
}
