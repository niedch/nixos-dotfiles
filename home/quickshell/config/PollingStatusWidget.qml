import Quickshell.Io
import QtQuick
import qs

Widget {
  id: root

  property int pollInterval: Constants.pollNormal
  property var checkCommand: []
  property string activeText: ""
  property bool active: false
  property bool invertResult: false
  property var toggleCommand: []
  property var toggleCommandWhenActive: []
  property var toggleCommandWhenInactive: []
  property bool checkOnInit: true

  widthPadding: 5
  pixelSize: Constants.fontSizeSmall

  text: active ? activeText : ""
  textColor: active ? Colors.color1 : Colors.foreground
  textVisible: active

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
