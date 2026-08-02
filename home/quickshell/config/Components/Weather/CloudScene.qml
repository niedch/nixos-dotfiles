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

  component CloudShape: Rectangle {
    property int driftDur: 8000
    radius: height / 2
    color: root.tint(Colors.color8, 0.5)
    y: parent.height * 0.5
    x: -width

    NumberAnimation on x {
      from: -width
      to: root.width
      duration: driftDur
      loops: Animation.Infinite
      running: root.active
    }
  }

  CloudShape {
    width: 46
    height: 20
    y: 14
    driftDur: 9000
  }
  CloudShape {
    width: 34
    height: 16
    y: 34
    driftDur: 7000
  }
  CloudShape {
    width: 40
    height: 18
    y: 52
    driftDur: 11000
  }
}
