import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import QtQuick

Item {
  implicitHeight: 26

  property bool drawerOpen: false

  Row {
    anchors.verticalCenter: parent.verticalCenter
    spacing: 0

    Text {
      id: expandIcon
      anchors.verticalCenter: parent.verticalCenter
      color: "#C5C9C7"
      font.family: "JetBrainsMono Nerd Font"
      font.pixelSize: 12
      text: drawerOpen ? "" : ""

      MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: drawerOpen = !drawerOpen
      }
    }

    Item { width: drawerOpen ? 4 : 0; height: 1 }

    Row {
      id: trayItems
      visible: drawerOpen
      spacing: 17
      clip: true

      Repeater {
        model: SystemTray.items

        delegate: Item {
          required property var modelData

          width: 12
          height: 26

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
  }
}
