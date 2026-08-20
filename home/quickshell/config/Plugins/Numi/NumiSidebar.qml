import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.Ui
import qs.Commons

Item {
  id: root

  // --- Interface Properties ---
  property var bar                    // Exposes parent's Bar object (for style, fontFamily, foreground)
  property alias notesModel: notesList.model  // Aliases ListView's model to bind notes data
  property int selectedNoteIndex: 0   // Tracks the selected index for delegation sync

  // --- Interface Signals ---
  signal newNoteClicked()             // Emitted when the "+" button is clicked
  signal switchNoteRequested(int index) // Emitted when a note delegate is clicked or return/enter is pressed

  // --- Interface Functions ---
  function focusList() {
    notesList.forceActiveFocus()      // Preserves original Ctrl+Tab focus-switching
  }

  Layout.preferredWidth: Style.space(190)
  Layout.fillHeight: true

  ColumnLayout {
    anchors.fill: parent
    spacing: Style.spacing.md

    // NOTES header + "+" button
    RowLayout {
      Layout.fillWidth: true

      Text {
        text: "NOTES"
        font.family: root.bar ? root.bar.fontFamily : "sans-serif"
        font.pixelSize: Style.font.caption
        font.bold: true
        color: root.bar ? Qt.darker(root.bar.foreground, 1.4) : "grey"
      }

      Item {
        Layout.fillWidth: true
      }

      Button {
        iconText: "+"
        tooltipText: "New note"
        foreground: root.bar ? root.bar.foreground : "white"
        fontFamily: root.bar ? root.bar.fontFamily : "sans-serif"
        fontSize: Style.font.bodySmall
        horizontalPadding: Style.spacing.controlPaddingX
        verticalPadding: Style.spacing.controlPaddingY
        onClicked: root.newNoteClicked()
      }
    }

    // notes list
    Item {
      Layout.fillWidth: true
      Layout.fillHeight: true

      ListView {
        id: notesList
        anchors.fill: parent
        clip: true
        spacing: Style.space(4)
        boundsBehavior: Flickable.StopAtBounds
        interactive: contentHeight > height
        currentIndex: root.selectedNoteIndex
        focus: true

        Keys.onReturnPressed: root.switchNoteRequested(currentIndex)
        Keys.onEnterPressed: root.switchNoteRequested(currentIndex)

        ScrollBar.vertical: NumiScrollBar {
          foregroundColor: root.bar ? root.bar.foreground : "white"
        }

        delegate: NumiNoteDelegate {
          selected: index === root.selectedNoteIndex
          foreground: root.bar ? root.bar.foreground : "white"
          fontFamily: root.bar ? root.bar.fontFamily : "sans-serif"
          onClicked: root.switchNoteRequested(index)
        }
      }

      Text {
        anchors.centerIn: parent
        visible: notesList.count === 0
        text: "no notes"
        color: root.bar ? Qt.darker(root.bar.foreground, 1.4) : "grey"
        font.family: root.bar ? root.bar.fontFamily : "sans-serif"
        font.pixelSize: Style.font.caption
      }
    }
  }
}
