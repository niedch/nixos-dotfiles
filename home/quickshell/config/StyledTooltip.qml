import Quickshell
import QtQuick
import qs

PopupWindow {
  id: root

  // Widget this tooltip belongs to. Positioned relative to it, and the
  // containing window is derived from it automatically.
  required property Item target
  // Set to the hover state of the target (e.g. mouseArea.containsMouse).
  property bool hovered: false
  property string tooltipText: ""
  property int tooltipDelay: 400

  property color textColor: Colors.foreground
  property color backgroundColor: Colors.background
  property color borderColor: Colors.color0
  property string fontFamily: Constants.fontFamily
  property real fontSize: Constants.fontSizeSmall
  property int paddingX: 10
  property int paddingY: 7
  property real gap: 6

  readonly property var anchorWindow: root.target && root.target.QsWindow ? root.target.QsWindow.window : null
  readonly property bool wantShow: root.hovered && root.tooltipText !== ""
  property bool shown: false

  visible: root.shown
  color: "transparent"
  implicitWidth: Math.ceil(bubble.implicitWidth)
  implicitHeight: Math.ceil(bubble.implicitHeight)

  Timer {
    id: delayTimer
    interval: root.tooltipDelay
    onTriggered: if (root.wantShow) root.shown = true
  }

  onWantShowChanged: {
    if (root.wantShow) {
      delayTimer.restart()
    } else {
      delayTimer.stop()
      root.shown = false
    }
  }

  anchor {
    id: tipAnchor
    window: root.anchorWindow
    adjustment: PopupAdjustment.Slide
    edges: Edges.Top | Edges.Left
    gravity: Edges.Bottom | Edges.Right
    rect.width: 1
    rect.height: 1

    onAnchoring: {
      if (!root.target || !root.anchorWindow) return
      var pw = root.implicitWidth
      var ph = root.implicitHeight
      var lx = root.target.width / 2 - pw / 2
      var ly = root.target.height + root.gap
      var pt = root.anchorWindow.contentItem.mapFromItem(root.target, lx, ly)
      tipAnchor.rect.x = Math.round(pt.x)
      tipAnchor.rect.y = Math.round(pt.y)
    }
  }

  Rectangle {
    id: bubble
    implicitWidth: label.implicitWidth + root.paddingX * 2
    implicitHeight: label.implicitHeight + root.paddingY * 2
    color: root.backgroundColor
    border.color: root.borderColor
    border.width: 1
    radius: 4

    Text {
      id: label
      anchors.centerIn: parent
      text: root.tooltipText
      color: root.textColor
      font.family: root.fontFamily
      font.pixelSize: root.fontSize
      horizontalAlignment: Text.AlignHCenter
      verticalAlignment: Text.AlignVCenter
    }
  }
}
