import QtQuick
import qs

Rectangle {
  id: chip

  required property var theme
  required property var eventData

  property color chipColor: theme && eventData
    ? (eventData.calendar_color ? String(eventData.calendar_color) : theme.calPalette[theme.calColorIndex(eventData)])
    : Colors.accent

  radius: 4
  color: theme ? theme.tint(chipColor, 0.18) : Qt.rgba(1, 1, 1, 0.1)
  border.color: Qt.rgba(chipColor.r, chipColor.g, chipColor.b, 0.4)
  border.width: 1
  clip: true

  signal clicked()

  Rectangle {
    width: 3
    anchors {
      left: parent.left
      top: parent.top
      bottom: parent.bottom
    }
    color: chipColor
  }

  Column {
    anchors {
      left: parent.left
      right: parent.right
      top: parent.top
      bottom: parent.bottom
      leftMargin: 6
      topMargin: 2
      bottomMargin: 2
      rightMargin: 3
    }
    spacing: 0

    Text {
      width: parent.width
      text: chip.eventData ? chip.eventData.summary : ""
      color: Colors.foreground
      font.family: Constants.fontFamily
      font.pixelSize: 10
      font.weight: Font.DemiBold
      elide: Text.ElideRight
    }

    Text {
      width: parent.width
      visible: !!chip.eventData && chip.height > 26
      text: {
        if (!chip.eventData) return ""
        if (chip.eventData.all_day) return "All day"
        return chip.theme.fmtRange(chip.eventData.startDate, chip.eventData.endDate)
      }
      color: Colors.color8
      font.family: Constants.fontFamily
      font.pixelSize: 9
      elide: Text.ElideRight
    }
  }

  MouseArea {
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onClicked: chip.clicked()
  }
}
