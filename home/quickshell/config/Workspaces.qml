import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick

Row {
  id: root
  spacing: 0
  height: 26

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
        color: isActive || isOccupied ? "#C5C9C7" : "#676C6D"
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 12
        text: {
          var labels = ["一", "二", "三", "四", "五", "六", "七", "八", "九", "十"]
          if (isActive) return "󱓻"
          return labels[wsId - 1]
        }
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

      visible: wsId > 5

      readonly property bool isActive: workspace.active

      width: visible ? textItem.implicitWidth + 12 : 0
      height: root.height

      Text {
        id: textItem
        anchors.centerIn: parent
        color: isActive ? "#C5C9C7" : "#9FA4A3"
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 12
        text: {
          var labels = ["一", "二", "三", "四", "五", "六", "七", "八", "九", "十"]
          if (isActive) return "󱓻"
          var label = wsId >= 1 && wsId <= 10 ? labels[wsId - 1] : String(wsId)
          return label
        }
      }

      MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: workspace.activate()
      }
    }
  }
}
