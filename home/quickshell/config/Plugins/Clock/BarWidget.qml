import Quickshell
import QtQuick
import qs
import qs.Ui
import qs.Commons
import qs.Components.Calendar

BarWidget {
  id: clock
  moduleName: "quickshell.clock"

  property int widthPadding: 17

  text: Qt.formatDateTime(clockSource.date, "dddd HH:mm")
  textVisible: text !== ""

  implicitHeight: Constants.barHeight
  implicitWidth: textVisible ? contentText.implicitWidth + widthPadding : 0

  Text {
    id: contentText
    anchors.centerIn: parent
    color: Color.foreground
    font.family: Constants.fontFamily
    font.pixelSize: Constants.fontSize
    text: clock.text
  }

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
