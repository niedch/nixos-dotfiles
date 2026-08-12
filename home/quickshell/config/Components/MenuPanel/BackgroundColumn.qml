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
  signal focusMenuRequested()
  signal focusNextRequested()
  signal focusPreviousRequested()
  property bool navigating: false

  Timer {
    id: navTimer
    interval: 200
    onTriggered: root.navigating = false
  }

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
    bgList.currentIndex = -1
    if (root.currentIndex >= 0) {
      bgList.positionViewAtIndex(root.currentIndex, ListView.Contain)
    }
  }

  function takeFocus() {
    bgList.currentIndex = root.currentIndex >= 0 ? root.currentIndex : 0
    bgList.positionViewAtIndex(bgList.currentIndex, ListView.Contain)
    bgList.forceActiveFocus()
  }

  function defocus() {
    bgList.currentIndex = -1
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
      font.pixelSize: Constants.fontSizeLarge
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
      currentIndex: -1
      model: root.backgrounds

      Keys.onUpPressed: {
        if (bgList.currentIndex > 0) {
          root.navigating = true
          navTimer.restart()
          bgList.currentIndex--
        }
      }
      Keys.onDownPressed: {
        if (bgList.currentIndex < bgList.count - 1) {
          root.navigating = true
          navTimer.restart()
          bgList.currentIndex++
        }
      }
      Keys.onReturnPressed: {
        if (bgList.currentIndex >= 0) {
          root.activate(root.backgrounds[bgList.currentIndex])
        }
      }
      Keys.onLeftPressed: root.focusMenuRequested()
      Keys.onEscapePressed: root.focusMenuRequested()
      Keys.onTabPressed: {
        root.focusNextRequested()
        event.accepted = true
      }
      Keys.onBacktabPressed: {
        root.focusPreviousRequested()
        event.accepted = true
      }

      delegate: Item {
        required property string modelData
        required property int index
        property bool isCurrent: modelData === root.currentBackground
        property bool isSelected: bgList.currentIndex === index

        width: bgList.width
        height: 84

        Rectangle {
          anchors.fill: parent
          anchors.leftMargin: 8
          anchors.rightMargin: 8
          radius: 6
          color: isSelected ? Colors.selectionBackground : "transparent"
          opacity: isSelected ? 0.7 : 1.0
          border.color: isCurrent ? Colors.accent : (!root.navigating && bgMouse.containsMouse ? Colors.selectionBackground : "transparent")
          border.width: isCurrent ? 2 : 1

          MouseArea {
            id: bgMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onPositionChanged: {
              if (!root.navigating) {
                bgList.currentIndex = index
              }
            }
            onClicked: {
              root.navigating = false
              navTimer.stop()
              root.activate(modelData)
            }
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
              font.pixelSize: Constants.fontSizeLarge
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
