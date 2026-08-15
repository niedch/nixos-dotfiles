import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import qs

Scope {
  id: root

  property bool open: false
  property string activeColumn: "menu"

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

  function focusMenu() {
    if (root.activeColumn === "theme") themeColumn.defocus()
    if (root.activeColumn === "background") backgroundColumn.defocus()
    root.activeColumn = "menu"
    menuColumn.focusSearch()
  }

  function focusTheme() {
    if (root.activeColumn === "background") backgroundColumn.defocus()
    root.activeColumn = "theme"
    themeColumn.takeFocus()
  }

  function focusBackground() {
    if (root.activeColumn === "theme") themeColumn.defocus()
    root.activeColumn = "background"
    backgroundColumn.takeFocus()
  }

  function focusNextColumn() {
    if (root.activeColumn === "theme") root.focusMenu()
    else if (root.activeColumn === "menu") root.focusBackground()
    else if (root.activeColumn === "background") root.focusTheme()
  }

  function focusPreviousColumn() {
    if (root.activeColumn === "theme") root.focusBackground()
    else if (root.activeColumn === "menu") root.focusTheme()
    else if (root.activeColumn === "background") root.focusMenu()
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
      border.color: Colors.accent
      border.width: 2
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
          onThemeSelected: root.close()
          onFocusMenuRequested: root.focusMenu()
          onFocusNextRequested: root.focusNextColumn()
          onFocusPreviousRequested: root.focusPreviousColumn()
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
          onMoveLeftRequested: root.focusTheme()
          onMoveRightRequested: root.focusBackground()
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
          onFocusMenuRequested: root.focusMenu()
          onFocusNextRequested: root.focusNextColumn()
          onFocusPreviousRequested: root.focusPreviousColumn()
        }
      }
    }
  }
}
