import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick
import qs

Row {
  id: root
  spacing: 0
  height: Constants.barHeight

  readonly property var workspaceLabels: ["一", "二", "三", "四", "五", "六", "七", "八", "九", "十"]
  readonly property string activeIcon: "󱓻"

  function labelFor(wsId) {
    return wsId >= 1 && wsId <= workspaceLabels.length ? workspaceLabels[wsId - 1] : String(wsId)
  }

  Repeater {
    model: 5

    delegate: Item {
      readonly property int wsId: index + 1

      readonly property bool isActive: Hyprland.focusedWorkspace !== null && Hyprland.focusedWorkspace.id === wsId

      readonly property bool isOccupied: {
        var vals = Hyprland.workspaces.values
        for (var i = 0; i < vals.length; i++) {
          if (vals[i].id === wsId) return true
        }
        return false
      }

      width: textItem.implicitWidth + 12
      height: root.height

      Text {
        id: textItem
        anchors.centerIn: parent
        color: Colors.foreground
        opacity: isActive || isOccupied ? 1.0 : 0.5
        font.family: Constants.fontFamily
        font.pixelSize: Constants.fontSize
        text: isActive ? root.activeIcon : root.labelFor(wsId)
      }

      MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: Hyprland.dispatch("workspace " + wsId)
      }
    }
  }

  Repeater {
    model: Hyprland.workspaces

    delegate: Item {
      readonly property var workspace: modelData
      readonly property int wsId: workspace.id

      readonly property bool isActive: workspace.active

      visible: wsId > 5
      width: visible ? textItem.implicitWidth + 12 : 0
      height: root.height

      Text {
        id: textItem
        anchors.centerIn: parent
        color: Colors.foreground
        opacity: isActive ? 1.0 : 0.5
        font.family: Constants.fontFamily
        font.pixelSize: Constants.fontSize
        text: isActive ? root.activeIcon : root.labelFor(wsId)
      }

      MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: workspace.activate()
      }
    }
  }
}
