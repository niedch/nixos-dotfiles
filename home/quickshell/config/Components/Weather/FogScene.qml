import QtQuick
import qs

Item {
  id: root
  property bool active: false
  visible: root.active
  anchors.fill: parent

  function tint(c, a) {
    var col = Qt.color(String(c))
    return Qt.rgba(col.r, col.g, col.b, a)
  }

  component FogBar: Rectangle {
    property int driftDur: 12000
    width: 90
    height: 10
    radius: 5
    color: root.tint(Colors.foreground, 0.12)
    x: -width
    y: parent.height * 0.4

    NumberAnimation on x {
      from: -width
      to: root.width
      duration: driftDur
      loops: Animation.Infinite
      running: root.active
    }

    SequentialAnimation on opacity {
      loops: Animation.Infinite
      running: root.active
      NumberAnimation {
        from: 0.3
        to: 1.0
        duration: 4000
        easing.type: Easing.InOutSine
      }
      NumberAnimation {
        from: 1.0
        to: 0.3
        duration: 4000
        easing.type: Easing.InOutSine
      }
    }
  }

  FogBar {
    y: 14
    driftDur: 14000
  }
  FogBar {
    y: 34
    driftDur: 10000
  }
  FogBar {
    y: 52
    driftDur: 18000
  }
}
