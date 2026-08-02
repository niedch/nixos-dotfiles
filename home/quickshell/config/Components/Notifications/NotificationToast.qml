import Quickshell.Services.Notifications
import Quickshell.Widgets
import QtQuick
import qs

Item {
  id: toast
  required property var model
  property int toastWidth: 0

  readonly property var notif: toast.model

  width: toast.toastWidth
  height: 56

  function urgencyColor() {
    if (toast.notif.urgency === NotificationUrgency.Critical) return Colors.color1
    if (toast.notif.urgency === NotificationUrgency.Normal) return Colors.accent
    return Colors.color8
  }

  Rectangle {
    anchors.fill: parent
    radius: 6
    color: Colors.background
    border.color: Colors.color0
    border.width: 1
  }

  Rectangle {
    id: accentBar
    anchors.left: parent.left
    anchors.top: parent.top
    anchors.bottom: parent.bottom
    width: 3
    radius: 1.5
    color: toast.urgencyColor()
  }

  Row {
    anchors.left: accentBar.right
    anchors.right: parent.right
    anchors.top: parent.top
    anchors.bottom: parent.bottom
    anchors.leftMargin: 8
    anchors.rightMargin: 8
    anchors.topMargin: 6
    anchors.bottomMargin: 6
    spacing: 6

    IconImage {
      id: toastIcon
      anchors.verticalCenter: parent.verticalCenter
      width: 14
      height: 14
      source: toast.notif.appIcon
      visible: toast.notif.appIcon !== ""
    }

    Column {
      anchors.verticalCenter: parent.verticalCenter
      width: parent.width - (toastIcon.visible ? toastIcon.width + parent.spacing : 0)
      spacing: 2

      Text {
        width: parent.width
        text: toast.notif.appName
        color: Colors.color8
        font.family: Constants.fontFamily
        font.pixelSize: Constants.fontSizeSmall
        font.bold: true
        elide: Text.ElideRight
      }

      Text {
        width: parent.width
        text: toast.notif.summary
        color: toast.urgencyColor()
        font.family: Constants.fontFamily
        font.pixelSize: Constants.fontSize
        font.weight: Font.DemiBold
        elide: Text.ElideRight
      }

      Text {
        width: parent.width
        visible: toast.notif.body !== ""
        text: toast.notif.body
        color: Colors.foreground
        font.family: Constants.fontFamily
        font.pixelSize: Constants.fontSizeSmall
        elide: Text.ElideRight
        maximumLineCount: 1
      }
    }
  }

  Text {
    anchors.right: parent.right
    anchors.top: parent.top
    anchors.rightMargin: 6
    anchors.topMargin: 3
    text: "󰅖"
    color: Colors.color8
    font.family: Constants.fontFamily
    font.pixelSize: Constants.fontSizeSmall

    MouseArea {
      anchors.fill: parent
      cursorShape: Qt.PointingHandCursor
      onClicked: Notifications.dismissToast(toast.notif.id)
    }
  }

  MouseArea {
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    onClicked: Notifications.dismiss(toast.notif.id)
  }
}
