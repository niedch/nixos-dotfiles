import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import qs

Item {
  id: root

  property var backgrounds: []
  property string currentBackground: ""
  property int currentIndex: -1
  property int reloadToken: 0

  readonly property string backgroundsDir: (Quickshell.env("HOME") ?? "") + "/.local/share/themes/current/backgrounds"

  function load() {
    root.reloadToken++
    listProc.running = true
    currentProc.running = true
  }

  function activate(name) {
    if (name === root.currentBackground) return
    switchProc.command = ["theme-wallpaper", name]
    switchProc.running = true
  }

  Process {
    id: listProc
    command: ["bash", "-c", "ls -1 \"$HOME/.local/share/themes/current/backgrounds\" 2>/dev/null | sort"]
    stdout: StdioCollector {
      id: listOut
    }
    onExited: {
      var names = listOut.text.trim().split("\n").filter(function (x) { return x !== "" })
      root.backgrounds = names
      root.updateCurrent()
    }
  }

  Process {
    id: currentProc
    command: ["bash", "-c", "basename \"$(readlink \"$HOME/.local/share/themes/current-background\")\" 2>/dev/null"]
    stdout: StdioCollector {
      id: currentOut
    }
    onExited: {
      root.currentBackground = currentOut.text.trim()
      root.updateCurrent()
    }
  }

  Process {
    id: switchProc
    onExited: {
      // refresh current marker after switching
      currentProc.running = true
    }
  }

  function updateCurrent() {
    root.currentIndex = root.backgrounds.indexOf(root.currentBackground)
  }

  ColumnLayout {
    anchors.fill: parent
    spacing: 0

    Text {
      Layout.fillWidth: true
      Layout.preferredHeight: 36
      horizontalAlignment: Text.AlignHCenter
      verticalAlignment: Text.AlignVCenter
      text: "󰸉 Backgrounds"
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
      id: bgList
      Layout.fillWidth: true
      Layout.fillHeight: true
      clip: true
      model: root.backgrounds

      delegate: Item {
        required property string modelData
        required property int index
        property bool isCurrent: modelData === root.currentBackground

        width: bgList.width
        height: 84

        Rectangle {
          anchors.fill: parent
          anchors.leftMargin: 8
          anchors.rightMargin: 8
          radius: 6
          color: "transparent"
          border.color: isCurrent ? Colors.accent : (bgMouse.containsMouse ? Colors.selectionBackground : "transparent")
          border.width: isCurrent ? 2 : 1

          MouseArea {
            id: bgMouse
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
                source: "file://" + root.backgroundsDir + "/" + modelData + "?t=" + root.reloadToken
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
              font.pixelSize: Constants.fontSizeSmall
              elide: Text.ElideRight
              wrapMode: Text.Wrap
              maximumLineCount: 2
            }
          }
        }
      }
    }
  }
}
