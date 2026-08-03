import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import qs

Item {
  id: root

  signal themeChanged()

  property var themes: []
  property string currentTheme: ""
  property int currentIndex: -1

  function load() {
    listProc.running = true
    currentProc.running = true
  }

  function activate(name) {
    if (name === root.currentTheme) return
    switchProc.command = ["theme-switcher-set", name]
    switchProc.running = true
  }

  Process {
    id: listProc
    command: ["bash", "-c", "ls -1 \"$HOME/.local/share/themes\" | grep -v -E '^(current|current-background)$' | sort"]
    stdout: StdioCollector {
      id: listOut
    }
    onExited: {
      var names = listOut.text.trim().split("\n").filter(function (x) { return x !== "" })
      root.themes = names
      root.updateCurrent()
    }
  }

  Process {
    id: currentProc
    command: ["bash", "-c", "basename \"$(readlink \"$HOME/.local/share/themes/current\")\" 2>/dev/null"]
    stdout: StdioCollector {
      id: currentOut
    }
    onExited: {
      root.currentTheme = currentOut.text.trim()
      root.updateCurrent()
    }
  }

  Process {
    id: switchProc
    onExited: {
      root.themeChanged()
      // refresh current marker after switching
      currentProc.running = true
    }
  }

  function updateCurrent() {
    root.currentIndex = root.themes.indexOf(root.currentTheme)
  }

  ColumnLayout {
    anchors.fill: parent
    spacing: 0

    Text {
      Layout.fillWidth: true
      Layout.preferredHeight: 36
      horizontalAlignment: Text.AlignHCenter
      verticalAlignment: Text.AlignVCenter
      text: "󰉼 Theme"
      color: Colors.foreground
      font.family: Constants.fontFamily
      font.pixelSize: Constants.fontSize
      font.bold: true
    }

    Rectangle {
      Layout.fillWidth: true
      height: 1
      color: Colors.color0
    }

    ListView {
      id: themeList
      Layout.fillWidth: true
      Layout.fillHeight: true
      clip: true
      model: root.themes

      delegate: Item {
        required property string modelData
        required property int index
        property bool isCurrent: modelData === root.currentTheme

        width: themeList.width
        height: 32

        Rectangle {
          anchors.fill: parent
          color: isCurrent ? Colors.selectionBackground : (themeMouse.containsMouse ? Colors.selectionBackground : "transparent")
          opacity: isCurrent || themeMouse.containsMouse ? 0.7 : 1.0

          MouseArea {
            id: themeMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.activate(modelData)
          }
        }

        Text {
          anchors.left: parent.left
          anchors.right: parent.right
          anchors.verticalCenter: parent.verticalCenter
          anchors.leftMargin: 12
          anchors.rightMargin: 12
          text: modelData
          color: isCurrent ? Colors.accent : Colors.foreground
          font.family: Constants.fontFamily
          font.pixelSize: Constants.fontSize
          elide: Text.ElideRight
        }
      }
    }
  }
}
