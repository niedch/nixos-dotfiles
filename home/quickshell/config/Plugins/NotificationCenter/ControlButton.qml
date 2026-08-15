import QtQuick
import qs

Rectangle {
  id: cb
  required property string label
  property bool active: false
  property bool enabled: true
  signal clickedBtn

  height: 22
  radius: 4
  color: cbHover.containsMouse ? Colors.color1 : (cb.active ? Colors.accent : Colors.color8)
  border.color: cb.active ? "transparent" : Colors.color0
  border.width: 1
  opacity: cb.enabled ? 1 : 0.4
  width: cbLabel.implicitWidth + 14

  Text {
    id: cbLabel
    anchors.centerIn: parent
    text: cb.label
    color: cb.active ? Colors.background : Colors.foreground
    font.family: Constants.fontFamily
    font.pixelSize: Constants.fontSizeSmall
  }

  MouseArea {
    id: cbHover
    anchors.fill: parent
    enabled: cb.enabled
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onClicked: cb.clickedBtn()
  }
}
