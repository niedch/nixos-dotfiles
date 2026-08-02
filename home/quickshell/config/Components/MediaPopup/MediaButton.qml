import Quickshell
import QtQuick
import qs

Item {
  id: btn
  required property string glyph
  property bool isEnabled: true
  property bool isActive: false
  property int btnSize: 28
  signal clickedBtn
  signal wheeled(real delta)

  width: btn.btnSize
  height: btn.btnSize

  Rectangle {
    anchors.fill: parent
    radius: Math.round(btn.btnSize / 2)
    color: mouse.containsMouse && btn.isEnabled ? Colors.color1 : "transparent"
  }

  Text {
    anchors.centerIn: parent
    text: btn.glyph
    color: btn.isEnabled ? (btn.isActive ? Colors.accent : Colors.foreground) : Colors.color8
    font.family: Constants.fontFamily
    font.pixelSize: Math.round(btn.btnSize * 0.55)
  }

  MouseArea {
    id: mouse
    anchors.fill: parent
    enabled: btn.isEnabled
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onClicked: btn.clickedBtn()
    onWheel: function(wheel) {
      btn.wheeled(wheel.angleDelta.y > 0 ? 0.05 : -0.05)
    }
  }
}
