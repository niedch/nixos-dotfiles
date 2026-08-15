import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import qs
import qs.Commons

Item {
  id: root

  signal themeChanged()
  signal themeSelected()
  signal focusMenuRequested()
  signal focusNextRequested()
  signal focusPreviousRequested()
  property bool navigating: false

  Timer {
    id: navTimer
    interval: 200
    onTriggered: root.navigating = false
  }

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
    themeList.currentIndex = -1
    if (root.currentIndex >= 0) {
      themeList.positionViewAtIndex(root.currentIndex, ListView.Contain)
    }
  }

  function takeFocus() {
    themeList.currentIndex = root.currentIndex >= 0 ? root.currentIndex : 0
    themeList.positionViewAtIndex(themeList.currentIndex, ListView.Contain)
    themeList.forceActiveFocus()
  }

  function defocus() {
    themeList.currentIndex = -1
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
      font.pixelSize: Constants.fontSizeLarge
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
      currentIndex: -1
      model: root.themes

      Keys.onUpPressed: {
        if (themeList.currentIndex > 0) {
          root.navigating = true
          navTimer.restart()
          themeList.currentIndex--
        }
      }
      Keys.onDownPressed: {
        if (themeList.currentIndex < themeList.count - 1) {
          root.navigating = true
          navTimer.restart()
          themeList.currentIndex++
        }
      }
      Keys.onReturnPressed: {
        if (themeList.currentIndex >= 0) {
          root.activate(root.themes[themeList.currentIndex])
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
        property bool isCurrent: modelData === root.currentTheme
        property bool isSelected: themeList.currentIndex === index

        width: themeList.width
        height: 84

        Rectangle {
          anchors.fill: parent
          anchors.leftMargin: 8
          anchors.rightMargin: 8
          radius: 6
          color: isSelected
            ? Util.alpha(Colors.accent, 0.12)
            : (!root.navigating && themeMouse.containsMouse ? Util.alpha(Colors.foreground, 0.08) : "transparent")
          border.color: (isCurrent || isSelected) ? Colors.accent : "transparent"
          border.width: (isCurrent || isSelected) ? 2 : 0

          MouseArea {
            id: themeMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onPositionChanged: {
              if (!root.navigating) {
                themeList.currentIndex = index
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
              font.pixelSize: Constants.fontSizeLarge
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
