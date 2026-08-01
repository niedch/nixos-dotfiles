import Quickshell
import QtQuick
import qs

Item {
  id: widget

  property int widthPadding: Constants.defaultPadding
  property int pixelSize: Constants.fontSize
  property string fontFamily: Constants.fontFamily
  property color textColor: Colors.foreground
  property string text: ""
  property bool textVisible: true
  property alias textItem: contentText

  implicitHeight: Constants.barHeight
  width: textVisible && text !== "" ? contentText.implicitWidth + widthPadding : 0

  Text {
    id: contentText
    anchors.centerIn: parent
    color: widget.textColor
    font.family: widget.fontFamily
    font.pixelSize: widget.pixelSize
    text: widget.text
    visible: widget.textVisible
  }
}
