import QtQuick
import QtQuick.Controls
import qs.Commons

Rectangle {
  id: row

  // --- Model / ListView Context ---
  required property int index
  required property string expr
  required property string result
  required property bool error
  required property bool pending

  // --- Configurable State and Styling ---
  property color foreground: "white"
  property color urgent: "red"
  property string fontFamily: "sans-serif"

  // --- Signals ---
  signal clicked()

  width: ListView.view.width
  height: Style.space(28)
  radius: Style.cornerRadius
  color: mouse.containsMouse
    ? Style.hoverFillFor(foreground, Color.accent)
    : "transparent"

  MouseArea {
    id: mouse
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onClicked: row.clicked()
  }

  Text {
    id: exprText
    anchors.left: parent.left
    anchors.leftMargin: Style.spacing.controlPaddingX
    anchors.right: resultText.left
    anchors.rightMargin: Style.space(8)
    anchors.verticalCenter: parent.verticalCenter
    text: expr
    color: Qt.darker(foreground, 1.4)
    font.family: fontFamily
    font.pixelSize: Style.font.body
    elide: Text.ElideRight
  }

  Text {
    id: resultText
    anchors.right: parent.right
    anchors.rightMargin: Style.spacing.controlPaddingX
    anchors.verticalCenter: parent.verticalCenter
    text: error ? "error" : pending ? "…" : result
    color: error
      ? urgent
      : pending
        ? Qt.darker(foreground, 1.4)
        : foreground
    font.family: fontFamily
    font.pixelSize: Style.font.body
    horizontalAlignment: Text.AlignRight
  }
}
