import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import qs
import qs.Components.MenuPanel

Scope {
  id: root

  property bool open: false

  function toggle() {
    if (root.open) root.close()
    else root.openMenu()
  }

  function openMenu() {
    root.open = true
    win.visible = true
    themeColumn.load()
    backgroundColumn.load()
    menuColumn.reset()
    menuColumn.clearSearch()
    menuColumn.focusSearch()
  }

  function close() {
    root.open = false
    win.visible = false
  }

  function showSystem() {
    root.openMenu()
    menuColumn.navigateTo("System")
  }

  IpcHandler {
    target: "menu"
    function toggle() { root.toggle() }
    function system() { root.showSystem() }
  }

  PanelWindow {
    id: win
    visible: root.open
    color: "transparent"
    focusable: true
    screen: Quickshell.primaryScreen

    anchors {
      top: true
      bottom: true
      left: true
      right: true
    }

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    WlrLayershell.namespace: "quickshell-menu"
    exclusionMode: ExclusionMode.Ignore

    MouseArea {
      id: backdrop
      anchors.fill: parent
      onClicked: root.close()
    }

    Rectangle {
      id: card
      anchors.centerIn: parent
      width: 860
      height: 540
      color: Colors.background
      border.color: Colors.color0
      border.width: 1
      radius: 12
      clip: true

      Rectangle {
        anchors.fill: parent
        radius: 12
        color: Colors.background
        opacity: 0.92
      }

      Row {
        anchors.fill: parent
        anchors.margins: 1
        spacing: 1

        ThemeColumn {
          id: themeColumn
          width: 280
          height: parent.height
          onThemeChanged: backgroundColumn.load()
        }

        Rectangle {
          width: 1
          height: parent.height
          color: Colors.color0
        }

        MenuColumn {
          id: menuColumn
          width: 298
          height: parent.height
          onActionActivated: root.close()
        }

        Rectangle {
          width: 1
          height: parent.height
          color: Colors.color0
        }

        BackgroundColumn {
          id: backgroundColumn
          width: 280
          height: parent.height
        }
      }
    }
  }
}
