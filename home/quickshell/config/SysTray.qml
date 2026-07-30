import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import QtQuick

Row {
  id: root
  spacing: 17
  height: 26

  Repeater {
    model: SystemTray.items

    delegate: Item {
      required property var modelData

      width: 12
      height: root.height

      IconImage {
        anchors.centerIn: parent
        width: 12
        height: 12
        source: modelData.icon
      }

      MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: Qt.PointingHandCursor
        onClicked: function(mouse) {
          if (modelData.menu && mouse.button === Qt.RightButton) {
            modelData.menu.open()
          }
        }
      }
    }
  }
}
