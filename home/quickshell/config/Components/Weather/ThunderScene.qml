import Quickshell
import QtQuick
import qs
import qs.Components.Weather

Item {
  id: root
  property bool active: false
  visible: root.active
  anchors.fill: parent

  function tint(c, a) {
    var col = Qt.color(String(c))
    return Qt.rgba(col.r, col.g, col.b, a)
  }

  RainScene {
    anchors.fill: parent
    active: root.active
  }

  Rectangle {
    id: thunderCloud
    anchors.horizontalCenter: parent.horizontalCenter
    y: 12
    width: 60
    height: 24
    radius: 12
    color: root.tint(Colors.color0, 0.9)
  }

  Rectangle {
    id: flashOverlay
    anchors.fill: parent
    color: "white"
    opacity: 0
    z: 6

    Timer {
      id: lightningTimer
      interval: 3500
      running: root.active
      repeat: true
      onTriggered: {
        flashAnim.restart()
        lightningTimer.interval = 2500 + Math.random() * 4000
      }
    }

    SequentialAnimation {
      id: flashAnim
      onStopped: flashOverlay.opacity = 0
      NumberAnimation {
        target: flashOverlay
        property: "opacity"
        from: 1
        to: 0.2
        duration: 60
      }
      NumberAnimation {
        target: flashOverlay
        property: "opacity"
        from: 0.2
        to: 0
        duration: 120
      }
    }
  }
}
