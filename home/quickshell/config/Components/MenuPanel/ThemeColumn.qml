import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import qs

Item {
  id: root

  signal themeChanged()
  signal themeSelected()

  property var themes: []
  property string currentTheme: ""
  property int currentIndex: -1

  readonly property string themesDir: (Quickshell.env("HOME") ?? "") + "/.local/share/themes"

  function load() {
    listProc.running = true
    currentProc.running = true
  }

  function activate(name) {
    if (name === root.currentTheme) return
    root.themeSelected()
    switchProc.command = ["theme-switcher", name]
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
        height: 84

        Rectangle {
          anchors.fill: parent
          anchors.leftMargin: 8
          anchors.rightMargin: 8
          radius: 6
          color: isCurrent ? Colors.selectionBackground : (themeMouse.containsMouse ? Colors.selectionBackground : "transparent")
          opacity: isCurrent || themeMouse.containsMouse ? 0.7 : 1.0

          MouseArea {
            id: themeMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.activate(modelData)
          }

          RowLayout {
            anchors.fill: parent
            anchors.margins: 4
            spacing: 8

            Rectangle {
              Layout.preferredWidth: 96
              Layout.preferredHeight: 60
              radius: 4
              clip: true
              color: Colors.color0

              Image {
                anchors.fill: parent
                source: "file://" + root.themesDir + "/" + modelData + "/preview.png"
                sourceSize.width: 192
                sourceSize.height: 120
                asynchronous: true
                fillMode: Image.PreserveAspectCrop
              }
            }

            Text {
              Layout.fillWidth: true
              text: modelData
              color: isCurrent ? Colors.accent : Colors.foreground
              font.family: Constants.fontFamily
              font.pixelSize: Constants.fontSize
              elide: Text.ElideRight
              wrapMode: Text.Wrap
              maximumLineCount: 2
              verticalAlignment: Text.AlignVCenter
            }
          }
        }
      }
    }
  }
}
