import QtQuick
import qs
import qs.Components.Notifications

Item {
  id: widget

  readonly property color textColor: Notifications.dnd ? Colors.color1 : Colors.foreground

  implicitHeight: Constants.barHeight
  width: glyph.implicitWidth + (Notifications.unread > 0 ? badge.width + 4 : 0) + 15

  Text {
    id: glyph
    anchors.left: parent.left
    anchors.leftMargin: 7
    anchors.verticalCenter: parent.verticalCenter
    color: widget.textColor
    font.family: Constants.fontFamily
    font.pixelSize: Constants.fontSize
    text: Notifications.dnd ? "󰂛" : "󰂚"
  }

  Rectangle {
    id: badge
    visible: Notifications.unread > 0
    anchors.left: glyph.right
    anchors.leftMargin: 4
    anchors.verticalCenter: parent.verticalCenter
    height: 14
    radius: height / 2
    color: Colors.color1
    width: Math.max(14, badgeText.implicitWidth + 8)

    Text {
      id: badgeText
      anchors.centerIn: parent
      text: Notifications.unread > 9 ? "9+" : String(Notifications.unread)
      color: Colors.background
      font.family: Constants.fontFamily
      font.pixelSize: 9
      font.bold: true
    }
  }

  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    cursorShape: Qt.PointingHandCursor
    onClicked: function(mouse) {
      if (mouse.button === Qt.RightButton) Notifications.toggleDnd()
      else Notifications.toggleCenter()
    }
  }

  NotificationCenter {
    target: widget
  }

  ToastHost {
    target: widget
  }
}
