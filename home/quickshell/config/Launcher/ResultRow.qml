import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import qs
import qs.Commons

Item {
  id: row
  required property var modelData
  required property int index
  required property bool isCurrent

  signal activated(int index)
  signal hovered(int index)

  width: ListView.view.width
  height: 44

  function iconPath(item) {
    if (item.kind !== "app" || !item.icon) return ""
    return Quickshell.iconPath(item.icon, true)
  }

  function glyph(item) {
    if (item.kind === "app") return "󰘔"
    if (item.kind === "symbol") return item.symbol
    if (item.kind === "calc") return "󰃬"
    if (item.kind === "web") return "󰇧"
    if (item.kind === "clipboard") return "󰆏"
    return "󰘔"
  }

  function title(item) {
    if (item.kind === "app") return item.name
    if (item.kind === "symbol") return item.symbol + "  " + item.name
    if (item.kind === "calc") return item.result
    if (item.kind === "web") return "Search: " + item.query
    if (item.kind === "clipboard") return item.preview
    return ""
  }

  function subtitle(item) {
    if (item.kind === "app") return item.genericName || item.comment || ""
    if (item.kind === "symbol") return item.name
    if (item.kind === "calc") return item.expr
    if (item.kind === "web") return item.url
    if (item.kind === "clipboard") return ""
    return ""
  }

  Rectangle {
    anchors.fill: parent
    color: row.isCurrent ? Util.alpha(Colors.accent, 0.12) : "transparent"
    border.color: row.isCurrent ? Colors.accent : "transparent"
    border.width: row.isCurrent ? 2 : 0

    MouseArea {
      anchors.fill: parent
      hoverEnabled: true
      onPositionChanged: row.hovered(row.index)
      onClicked: row.activated(row.index)
    }

    RowLayout {
      anchors.fill: parent
      anchors.leftMargin: 16
      anchors.rightMargin: 16
      spacing: 12

      Item {
        Layout.preferredWidth: 28
        Layout.preferredHeight: 28

        IconImage {
          anchors.fill: parent
          source: row.iconPath(row.modelData)
          visible: row.iconPath(row.modelData) !== ""
        }

        Text {
          anchors.centerIn: parent
          visible: row.iconPath(row.modelData) === ""
          text: row.glyph(row.modelData)
          color: Colors.foreground
          font.family: Constants.fontFamily
          font.pixelSize: 18
        }
      }

      ColumnLayout {
        Layout.fillWidth: true
        spacing: 0

        Text {
          Layout.fillWidth: true
          text: row.title(row.modelData)
          color: Colors.foreground
          font.family: Constants.fontFamily
          font.pixelSize: Constants.fontSize
          elide: Text.ElideRight
        }

        Text {
          Layout.fillWidth: true
          visible: row.subtitle(row.modelData) !== ""
          text: row.subtitle(row.modelData)
          color: Qt.darker(Colors.foreground, 1.5)
          font.family: Constants.fontFamily
          font.pixelSize: Constants.fontSizeSmall
          elide: Text.ElideRight
        }
      }
    }
  }
}
