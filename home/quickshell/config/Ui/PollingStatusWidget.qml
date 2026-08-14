import Quickshell.Io
import QtQuick
import qs
import qs.Ui
import qs.Commons

BarWidget {
  id: root

  moduleName: ""

  property int pollInterval: Constants.pollNormal
  property var checkCommand: []
  property string activeText: ""
  property bool active: false
  property bool invertResult: false
  property var toggleCommand: []
  property var toggleCommandWhenActive: []
  property var toggleCommandWhenInactive: []
  property bool checkOnInit: true

  property int widthPadding: 5
  property int pixelSize: Constants.fontSizeSmall
  property color textColor: active ? Color.urgent : Color.foreground
  property bool textVisible: active
  property string text: active ? activeText : ""

  implicitHeight: Constants.barHeight
  implicitWidth: textVisible && text !== "" ? contentText.implicitWidth + widthPadding : 0

  Text {
    id: contentText
    anchors.centerIn: parent
    color: root.textColor
    font.family: Constants.fontFamily
    font.pixelSize: root.pixelSize
    text: root.text
    visible: root.textVisible
  }

  Timer {
    id: pollTimer
    interval: root.pollInterval
    running: true
    repeat: true
    onTriggered: check.running = true
  }

  Process {
    id: check
    command: root.checkCommand
    stdout: StdioCollector { id: output }
    onExited: {
      var found = output.text.trim() !== ""
      root.active = root.invertResult ? !found : found
    }
  }

  MouseArea {
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    onClicked: {
      var cmd = root.toggleCommand
      if (root.active && root.toggleCommandWhenActive.length > 0) cmd = root.toggleCommandWhenActive
      if (!root.active && root.toggleCommandWhenInactive.length > 0) cmd = root.toggleCommandWhenInactive
      if (cmd.length > 0) {
        toggle.command = cmd
        toggle.running = true
      }
      check.running = true
    }
  }

  Process { id: toggle }

  Component.onCompleted: if (root.checkOnInit) check.running = true
}
