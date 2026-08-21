import QtQuick
import QtQuick.Controls

ScrollBar {
  id: control

  property color foregroundColor: "white"
  property var flickable: parent

  visible: flickable ? (flickable.contentHeight > flickable.height) : false
  policy: ScrollBar.AsNeeded

  contentItem: Rectangle {
    color: Qt.darker(control.foregroundColor, 2.2)
    opacity: control.visible ? 0.7 : 0
    radius: width / 2
    implicitWidth: 4
    implicitHeight: 4
  }

  background: Rectangle {
    visible: control.visible
    color: Qt.rgba(control.foregroundColor.r, control.foregroundColor.g, control.foregroundColor.b, 0.12)
    radius: width / 2
  }
}
