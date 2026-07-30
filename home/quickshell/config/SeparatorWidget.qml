import QtQuick

Item {
  implicitHeight: 26
  width: label.implicitWidth + 2

  Text {
    id: label
    anchors.centerIn: parent
    color: "#C5C9C7"
    font.family: "JetBrainsMono Nerd Font"
    font.pixelSize: 12
    text: "|"
  }
}
