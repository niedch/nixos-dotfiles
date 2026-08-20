import QtQuick
import QtQuick.Controls
import qs.Commons

Rectangle {
  id: nrow

  // --- Model / ListView Context ---
  required property int index
  required property string title
  required property int lineCount

  // --- Configurable State and Styling ---
  property bool selected: false
  property color foreground: "white"
  property string fontFamily: "sans-serif"

  // --- Signals ---
  signal clicked()

  width: ListView.view.width
  height: Math.max(Style.space(30), titleLabel.implicitHeight + countLabel.implicitHeight + Style.space(8))
  radius: Style.cornerRadius
  color: selected
    ? Style.selectedFillFor(foreground, Color.accent)
    : mouse.containsMouse
      ? Style.hoverFillFor(foreground, Color.accent)
      : "transparent"

  MouseArea {
    id: mouse
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onClicked: nrow.clicked()
  }

  Column {
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.verticalCenter: parent.verticalCenter
    anchors.leftMargin: Style.spacing.controlPaddingX
    anchors.rightMargin: Style.spacing.controlPaddingX
    spacing: Style.space(1)

    Text {
      id: titleLabel
      width: parent.width
      text: title === "" ? "(empty note)" : title
      color: selected ? foreground : Qt.darker(foreground, 1.4)
      font.family: fontFamily
      font.pixelSize: Style.font.bodySmall
      font.bold: selected
      elide: Text.ElideRight
    }

    Text {
      id: countLabel
      width: parent.width
      visible: lineCount > 0
      text: lineCount + " line" + (lineCount > 1 ? "s" : "")
      color: Qt.darker(foreground, 1.8)
      font.family: fontFamily
      font.pixelSize: Style.font.caption
      elide: Text.ElideRight
    }
  }
}
