import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.Commons

ColumnLayout {
  id: root

  // --- Interface Properties ---
  property var bar                    // Exposes styling constraints
  property bool numrAvailable: true   // Tracks CLI process presence
  property string statusText: ""      // Holds "evaluating...", "copied", or errors
  property alias resultModel: resultsList.model // Binds evaluation results data

  // --- Interface Signals ---
  signal resultClicked(int index)     // Emitted when a result row is clicked to trigger clipboard copy

  spacing: Style.spacing.md
  Layout.fillWidth: true
  Layout.fillHeight: true

  // Results section header: label + busy/warning status.
  RowLayout {
    Layout.fillWidth: true

    Text {
      text: "RESULTS"
      font.family: root.bar ? root.bar.fontFamily : "sans-serif"
      font.pixelSize: Style.font.caption
      font.bold: true
      font.letterSpacing: 1.2
      color: root.bar ? Qt.darker(root.bar.foreground, 1.4) : "grey"
    }

    Item {
      Layout.fillWidth: true
    }

    Text {
      id: statusLabel
      text: root.numrAvailable ? root.statusText : "numr-cli not found"
      font.family: root.bar ? root.bar.fontFamily : "sans-serif"
      font.pixelSize: Style.font.caption
      color: root.numrAvailable
        ? (root.bar ? Qt.darker(root.bar.foreground, 1.4) : "grey")
        : (root.bar ? root.bar.urgent : "red")
    }
  }

  // Scrollable result rows; one per non-empty scratchpad line.
  Item {
    Layout.fillWidth: true
    Layout.fillHeight: true

    ListView {
      id: resultsList
      anchors.fill: parent
      clip: true
      spacing: Style.space(4)
      boundsBehavior: Flickable.StopAtBounds
      interactive: contentHeight > height

      ScrollBar.vertical: NumiScrollBar {
        foregroundColor: root.bar ? root.bar.foreground : "white"
      }

      delegate: NumiResultDelegate {
        foreground: root.bar ? root.bar.foreground : "white"
        urgent: root.bar ? root.bar.urgent : "red"
        fontFamily: root.bar ? root.bar.fontFamily : "sans-serif"
        onClicked: root.resultClicked(index)
      }
    }

    Text {
      anchors.centerIn: parent
      visible: resultsList.count === 0
      text: "type an expression above"
      color: root.bar ? Qt.darker(root.bar.foreground, 1.4) : "grey"
      font.family: root.bar ? root.bar.fontFamily : "sans-serif"
      font.pixelSize: Style.font.caption
    }
  }
}
