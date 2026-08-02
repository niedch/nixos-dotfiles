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

  component SunRay: Rectangle {
    anchors.centerIn: parent
    width: 4
    height: 32
    radius: 2
    color: root.tint(Colors.color3, 0.9)
  }

  Item {
    id: sunGroup
    anchors.centerIn: parent
    width: 80
    height: 80
    opacity: 0.95

    RotationAnimation on rotation {
      from: 0
      to: 360
      duration: 12000
      loops: Animation.Infinite
      running: root.active
    }

    SunRay {}
    SunRay { rotation: 60 }
    SunRay { rotation: 120 }

    Rectangle {
      anchors.centerIn: parent
      width: 20
      height: 20
      radius: 10
      color: root.tint(Colors.color3, 1)

      SequentialAnimation on scale {
        loops: Animation.Infinite
        running: root.active
        NumberAnimation {
          from: 1.0
          to: 1.15
          duration: 1200
          easing.type: Easing.InOutSine
        }
        NumberAnimation {
          from: 1.15
          to: 1.0
          duration: 1200
          easing.type: Easing.InOutSine
        }
      }
    }
  }
}
