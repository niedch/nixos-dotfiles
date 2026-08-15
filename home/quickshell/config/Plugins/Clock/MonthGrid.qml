import QtQuick
import qs

Item {
  id: monthGrid

  required property var theme
  required property var events
  signal dayClicked(var day)

  readonly property int headerHeight: 24
  readonly property real cellWidth: width / 7
  readonly property real cellHeight: (height - headerHeight) / 6
  readonly property var gridStart: theme.mondayOf(theme.firstOfMonth(theme.monthAnchor))

  function eventsFor(day) {
    var out = []
    for (var i = 0; i < events.length; i++) {
      if (theme.overlapsDay(events[i], day)) out.push(events[i])
    }
    return out
  }

  Row {
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    height: monthGrid.headerHeight

    Repeater {
      model: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]
      delegate: Text {
        width: monthGrid.cellWidth
        height: monthGrid.headerHeight
        text: modelData
        color: Colors.color8
        font.family: Constants.fontFamily
        font.pixelSize: Constants.fontSizeSmall
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
      }
    }
  }

  Repeater {
    model: 42
    delegate: Item {
      id: cell
      x: index % 7 * monthGrid.cellWidth
      y: monthGrid.headerHeight + Math.floor(index / 7) * monthGrid.cellHeight
      width: monthGrid.cellWidth
      height: monthGrid.cellHeight

      property var day: theme.addDays(monthGrid.gridStart, index)
      property bool inMonth: day.getMonth() === theme.monthAnchor.getMonth()
      property bool isToday: theme.sameDay(day, theme.now)
      property bool isSelected: theme.sameDay(day, theme.selectedDate)
      property var dayEvents: monthGrid.eventsFor(day)

      Rectangle {
        anchors.fill: parent
        anchors.margins: 2
        radius: 6
        color: cellHover.containsMouse ? Qt.rgba(1, 1, 1, 0.06) : "transparent"
      }

      Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 2
        width: 26
        height: 26
        radius: 13
        color: cell.isToday
          ? theme.tint(Colors.accent, 0.18)
          : (cell.isSelected ? theme.tint(Colors.foreground, 0.12) : "transparent")
        border.color: (cell.isToday || cell.isSelected) ? Colors.accent : "transparent"
        border.width: (cell.isToday || cell.isSelected) ? 2 : 0

        Text {
          anchors.centerIn: parent
          text: cell.day.getDate()
          color: cell.inMonth ? Colors.foreground : Colors.color8
          font.family: Constants.fontFamily
          font.pixelSize: 11
          font.weight: cell.isToday ? Font.DemiBold : Font.Normal
        }
      }

      Row {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 3
        spacing: 3

        Repeater {
          model: Math.min(3, cell.dayEvents.length)
          delegate: Rectangle {
            width: 4
            height: 4
            radius: 2
            color: cell.dayEvents[index].calendar_color
              ? String(cell.dayEvents[index].calendar_color)
              : theme.calPalette[theme.calColorIndex(cell.dayEvents[index])]
          }
        }

        Text {
          visible: cell.dayEvents.length > 3
          text: "+" + (cell.dayEvents.length - 3)
          color: Colors.color8
          font.family: Constants.fontFamily
          font.pixelSize: 8
        }
      }

      MouseArea {
        id: cellHover
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: monthGrid.dayClicked(cell.day)
      }
    }
  }
}
