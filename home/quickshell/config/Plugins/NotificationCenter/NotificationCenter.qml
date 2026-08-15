import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import qs

PopupWindow {
  id: root

  required property Item target
  property bool shown: false
  property int gap: 6

  readonly property var anchorWindow: root.target && root.target.QsWindow ? root.target.QsWindow.window : null

  visible: root.shown
  color: "transparent"
  implicitWidth: 360

  property int headerHeight: 36
  property int cardHeight: 78
  property int maxCards: 8
  property int listHeight: Math.min(Notifications.notifications.length, root.maxCards) * root.cardHeight

  readonly property int emptyHeight: 40

  implicitHeight: root.headerHeight + (Notifications.notifications.length === 0 ? root.emptyHeight : root.listHeight) + 16

  function toggle() {
    root.shown = !root.shown
    Notifications.centerOpen = root.shown
    if (root.shown) Notifications.markSeen()
  }

  HyprlandFocusGrab {
    windows: [root]
    active: root.shown
    onCleared: {
      root.shown = false
      Notifications.closeCenter()
    }
  }

  anchor {
    id: popAnchor
    window: root.anchorWindow
    adjustment: PopupAdjustment.Slide
    edges: Edges.Top | Edges.Left
    gravity: Edges.Bottom | Edges.Right
    rect.width: 1
    rect.height: 1

    onAnchoring: {
      if (!root.target || !root.anchorWindow) return
      var lx = root.target.width / 2 - root.implicitWidth / 2
      var ly = root.target.height + root.gap
      var pt = root.anchorWindow.contentItem.mapFromItem(root.target, lx, ly)
      popAnchor.rect.x = Math.round(pt.x)
      popAnchor.rect.y = Math.round(pt.y)
    }
  }

  Rectangle {
    id: card
    width: root.implicitWidth
    height: root.implicitHeight
    color: Colors.background
    border.color: Colors.color0
    border.width: 1
    radius: 8

    Column {
      anchors.fill: parent
      anchors.margins: 8
      spacing: 4

      RowLayout {
        width: parent.width
        height: root.headerHeight
        spacing: 6

        Text {
          text: "󰂚 Notifications"
          color: Colors.foreground
          font.family: Constants.fontFamily
          font.pixelSize: Constants.fontSize
          font.bold: true
        }

        Text {
          text: Notifications.unread > 0 ? "(" + Notifications.unread + ")" : ""
          color: Colors.color1
          font.family: Constants.fontFamily
          font.pixelSize: Constants.fontSizeSmall
        }

        Item {
          height: 1
          Layout.fillWidth: true
        }

        ControlButton {
          label: "󰆴 Clear"
          visible: Notifications.notifications.length > 0
          onClickedBtn: Notifications.clear()
        }
      }

      ListView {
        width: parent.width
        height: root.listHeight
        visible: Notifications.notifications.length > 0
        clip: true
        model: Notifications.notifications

        delegate: NotificationCard {
          cardWidth: ListView.view.width
        }
      }

      Text {
        width: parent.width
        visible: Notifications.notifications.length === 0
        height: root.emptyHeight
        text: "No notifications"
        color: Colors.color8
        font.family: Constants.fontFamily
        font.pixelSize: Constants.fontSizeSmall
        verticalAlignment: Text.AlignVCenter
      }
    }
  }
}
