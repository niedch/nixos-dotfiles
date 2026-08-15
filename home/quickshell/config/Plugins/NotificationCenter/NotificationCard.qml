import Quickshell.Services.Notifications
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import qs

Item {
  id: card
  required property var model
  property int cardWidth: 0

  readonly property var notif: card.model

  width: card.cardWidth
  height: 78 + (card.notif.image !== "" ? 32 : 0)

  function urgencyColor() {
    if (card.notif.urgency === NotificationUrgency.Critical) return Colors.color1
    if (card.notif.urgency === NotificationUrgency.Normal) return Colors.foreground
    return Colors.color8
  }

  function timeLabel() {
    var ms = Date.now() - card.notif.time
    var s = Math.floor(ms / 1000)
    if (s < 60) return s + "s"
    var m = Math.floor(s / 60)
    if (m < 60) return m + "m"
    var h = Math.floor(m / 60)
    if (h < 24) return h + "h"
    return Math.floor(h / 24) + "d"
  }

  Rectangle {
    anchors.fill: parent
    radius: 6
    color: cardHover.hovered ? Colors.color1 : "transparent"
  }

  Column {
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: parent.top
    anchors.margins: 8
    spacing: 2

    Row {
      visible: card.notif.image !== ""
      width: parent.width
      height: 28
      Image {
        anchors.verticalCenter: parent.verticalCenter
        source: card.notif.image
        width: 28
        height: 28
        fillMode: Image.PreserveAspectFit
      }
    }

    Row {
      width: parent.width
      spacing: 6

      Image {
        id: cardIcon
        anchors.verticalCenter: parent.verticalCenter
        width: 14
        height: 14
        source: card.notif.appIcon
        visible: card.notif.appIcon !== ""
        sourceSize.width: 14
        sourceSize.height: 14
      }

      Text {
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width - timeText.implicitWidth - parent.spacing * (cardIcon.visible ? 2 : 1) - (cardIcon.visible ? cardIcon.width : 0)
        text: card.notif.appName
        color: Colors.color8
        font.family: Constants.fontFamily
        font.pixelSize: Constants.fontSizeSmall
        font.bold: true
        elide: Text.ElideRight
      }

      Text {
        id: timeText
        anchors.verticalCenter: parent.verticalCenter
        text: card.timeLabel()
        color: Colors.color8
        font.family: Constants.fontFamily
        font.pixelSize: Constants.fontSizeSmall
      }
    }

    Text {
      width: parent.width
      text: card.notif.summary
      color: card.urgencyColor()
      font.family: Constants.fontFamily
      font.pixelSize: Constants.fontSize
      font.weight: Font.DemiBold
      elide: Text.ElideRight
    }

    Text {
      width: parent.width
      visible: card.notif.body !== ""
      text: card.notif.body
      color: Colors.foreground
      font.family: Constants.fontFamily
      font.pixelSize: Constants.fontSizeSmall
      elide: Text.ElideRight
      maximumLineCount: 1
    }
  }

  RowLayout {
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    anchors.margins: 8
    visible: card.notif.actions.length > 0
    spacing: 4

    Repeater {
      model: card.notif.actions

      delegate: ControlButton {
        required property var model
        label: model.label
        onClickedBtn: Notifications.invokeAction(card.notif.id, model.id)
      }
    }

    Item {
      height: 1
      Layout.fillWidth: true
      Layout.fillHeight: true
    }

    Text {
      text: "󰅖"
      color: Colors.color8
      font.family: Constants.fontFamily
      font.pixelSize: Constants.fontSizeSmall

      MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: Notifications.dismiss(card.notif.id)
      }
    }
  }

  HoverHandler {
    id: cardHover
    cursorShape: Qt.PointingHandCursor
  }
}
