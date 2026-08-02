import QtQuick
import qs

Item {
  id: root
  property bool active: false
  visible: root.active
  anchors.fill: parent

  component StarDot: Rectangle {
    id: star
    property int twinkleDur: 2000
    SequentialAnimation on opacity {
      loops: Animation.Infinite
      running: root.active
      NumberAnimation {
        from: 0.1
        to: 1.0
        duration: star.twinkleDur / 2
        easing.type: Easing.InOutSine
      }
      NumberAnimation {
        from: 1.0
        to: 0.1
        duration: star.twinkleDur / 2
        easing.type: Easing.InOutSine
      }
    }
  }

  Item {
    id: moonGroup
    anchors.centerIn: parent
    width: 60
    height: 60

    Rectangle {
      anchors.centerIn: parent
      width: 26
      height: 26
      radius: 13
      color: Qt.rgba(1, 1, 1, 0.85)
    }

    Rectangle {
      anchors.horizontalCenter: parent.horizontalCenter
      y: 6
      width: 22
      height: 22
      radius: 11
      color: Colors.background
    }

    StarDot {
      x: 6
      y: 4
      width: 3
      height: 3
      radius: 1.5
      color: Colors.foreground
    }
    StarDot {
      x: 42
      y: 10
      width: 2
      height: 2
      radius: 1
      color: Colors.foreground
      twinkleDur: 3000
    }
    StarDot {
      x: 48
      y: 40
      width: 2.5
      height: 2.5
      radius: 1.25
      color: Colors.foreground
      twinkleDur: 2500
    }
  }
}
